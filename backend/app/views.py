from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json
import random
from datetime import datetime
from os.path import join, dirname
from ibm_watson import SpeechToTextV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from django.core.files.storage import FileSystemStorage
from ibm_watson import NaturalLanguageUnderstandingV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from ibm_watson.natural_language_understanding_v1 \
    import Features, EmotionOptions
# from modelscope.pipelines import pipeline
# from modelscope.utils.constant import Tasks
# import numpy as np
import base64
import tempfile
from pydub import AudioSegment
import requests


def user_exists(username):
    """
    Check if the user exists in the database.
    """
    query = '''
        SELECT EXISTS (
            SELECT 1
            FROM users
            WHERE username = %s
        )
    '''
    with connection.cursor() as cursor:
        cursor.execute(query, [username])
        row = cursor.fetchone()
        return row[0]

def add_to_sentiment_table(username, interview_id, question_id, emotion, accuracy):
    query = """
        INSERT INTO emotionsummary (username, interview_id, question_id, emotion, accuracy)
        VALUES (%s, %s, %s, %s, %s);
    """
    with connection.cursor() as cursor:
        cursor.execute(query, [username, interview_id, question_id, emotion, accuracy])

def add_to_speech_emotion_table(interview_id, question_id, emotion, confidence_lvl):
    query = """
        INSERT INTO speech_emotion_results (interview_id, question_id, emotion, confidence_lvl)
        VALUES (%s, %s, %s, %s);
    """
    with connection.cursor() as cursor:
        cursor.execute(query, [interview_id, question_id, emotion, confidence_lvl])

def speechToText(base64_audio_string):

    authenticator = IAMAuthenticator('pIG-F8xSZWLOaYwiZDIe0-ITjWw7Rk8M7c9Vzqq9bi8s')
    speech_to_text = SpeechToTextV1(
        authenticator=authenticator
    )
    speech_to_text.set_service_url('https://api.au-syd.speech-to-text.watson.cloud.ibm.com/instances/8ec4f5a4-43d4-4866-a13a-1b11d1a7feb0')

    audio_data = base64.b64decode(base64_audio_string)

    with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as temp_audio_file:
        temp_audio_file_name = temp_audio_file.name
        temp_audio_file.write(audio_data)
        
    audio_segment = AudioSegment.from_file(temp_audio_file_name)
    converted_temp_audio_file_name = temp_audio_file_name + '.flac'
    audio_segment.export(converted_temp_audio_file_name, format='flac')
    
    with open(converted_temp_audio_file_name, 'rb') as audio_file:
        speech_recognition_results = speech_to_text.recognize(
            audio=audio_file,
        ).get_result()
    
    return {"audio": str(audio_data), "speech_recognition_results": speech_recognition_results}


def sentimentAPI(input_text):
    authenticator = IAMAuthenticator('5UoLws0msT8fi8c45kO08Qc_TNJTJoXE9G_MazEx5mZm')
    natural_language_understanding = NaturalLanguageUnderstandingV1(
        version='2022-04-07',
        authenticator=authenticator
    )

    natural_language_understanding.set_service_url('https://api.us-east.natural-language-understanding.watson.cloud.ibm.com/instances/fc76a36b-a5a5-41c5-a8f6-1bbbbb6330de')

    response = natural_language_understanding.analyze(
        text=input_text,
        features=Features(emotion=EmotionOptions())).get_result()
    emotion_dict = response["emotion"]["document"]["emotion"]
    out = []
    for emotion, score in emotion_dict.items():
        out.append((emotion, score))
    return out


@csrf_exempt
def getquestions(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    username = request.GET.get('username')
    num_questions = request.GET.get('num_questions')

    # make sure username and questions are passed in
    if not username or not num_questions:
        return JsonResponse({'message': 'Username and num_questions are required', 'status': 'fail'}, status=400)

    username = str(username) 
    num_questions = int(num_questions)

    # check to see if user is in the database
    if not user_exists(username):
        return JsonResponse({'message': 'User not found', 'status': 'fail'}, status=404)
    
    # generate question_id and questions; making sure the questions arent repeated
    query = """
        SELECT question_id, question
        FROM default_questions
        WHERE default_questions.question_id NOT IN (
            SELECT question_id
            FROM question_responses
            WHERE username = %s
        )
        LIMIT %s;
    """
    with connection.cursor() as cursor:
        cursor.execute(query, [username, num_questions])
        rows = cursor.fetchall()
        question_data = [{row[0]: row[1]} for row in rows]

    while True:
        interview_id = random.randint(100000, 999999)  # Generate a random interview ID
        query = 'SELECT COUNT(*) FROM question_responses WHERE interview_id = %s'
        with connection.cursor() as cursor:
            cursor.execute(query, [interview_id])
            count = cursor.fetchone()[0]
            if count == 0:
                break
    
    # return data in JSON 
    return JsonResponse({'interview_id': interview_id, 'questions':question_data, 'status': 'success' })


@csrf_exempt
def postanswers(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    try:
        json_data = json.loads(request.body)
        username = json_data['username']
        interview_id = json_data['interview_id']
        question_id = json_data['question_id']
        question_answer = json_data['question_answer']
        audio = json_data['audio']
        video_file_path = json_data['video_file_path']
    except KeyError as e:
        return JsonResponse({'message': f'Missing required parameter: {e}', 'status': 'fail'}, status=400)
    except json.JSONDecodeError:
        return JsonResponse({'message': 'Invalid JSON format', 'status': 'fail'}, status=400)
    
    if (audio):
        speechEmotionResults = speech_emotion_analysis(audio)
        add_to_speech_emotion_table(interview_id, question_id, speechEmotionResults["emotion"], speechEmotionResults["confidence"])
    # else:
    #     sentimentAnalysis = (sentimentAPI(question_answer))
    #     for emotion, value in sentimentAnalysis:
    #         add_to_sentiment_table(username, interview_id, question_id, emotion, value)

    timestamp = datetime.now() 

    query = """
        INSERT INTO question_responses (username, interview_id, question_id, question_answer, timestamp, audio, video_file_path)
        VALUES (%s, %s, %s, %s, %s, %s, %s);
    """
    with connection.cursor() as cursor:
        cursor.execute(query, [username, interview_id, question_id, question_answer, timestamp, audio, video_file_path])

    return JsonResponse({'status': 'success'}, status=201)


@csrf_exempt
def getusersummary(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    username = request.GET.get('username')

    # Make sure username is passed in
    if not username:
        return JsonResponse({'message': 'Username is required', 'status': 'fail'}, status=400)

    # Check if user exists in the database
    if not user_exists(username):
        return JsonResponse({'message': 'User not found', 'status': 'fail'}, status=404)
    
    # List all questions and answers sorted by time 
    query = """
    SELECT q.question, qr.question_answer
    FROM question_responses qr
    JOIN default_questions q ON qr.question_id = q.question_id
    WHERE qr.username = %s
    ORDER BY qr.timestamp DESC;
    """

    with connection.cursor() as cursor:
        cursor.execute(query, [username])
        rows = cursor.fetchall()

    return JsonResponse({'status': 'success', 'data': rows})


@csrf_exempt
def getfeedback(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    username = request.GET.get('username')
    interview_id = request.GET.get('interview_id')

    query = """
        SELECT qr.question_id, dq.question
        FROM question_responses qr
        INNER JOIN default_questions dq ON qr.question_id = dq.question_id
        WHERE qr.interview_id = %s
        ORDER BY qr.question_id ASC;
    """
    response_data = []

    with connection.cursor() as cursor:
        cursor.execute(query, [interview_id])
        asked_questions_info = cursor.fetchall()

        for question_info in asked_questions_info:
            question_id = question_info[0]
            question = question_info[1]

            sentiment_query = """
                SELECT e.emotion, e.accuracy
                FROM emotionsummary e
                WHERE e.interview_id = %s AND e.question_id = %s
                ORDER BY e.emotion ASC;
            """
            cursor.execute(sentiment_query, [interview_id, question_id])
            sentiment_query_results = cursor.fetchall()

            speech_emotion_query = """
                SELECT sm.emotion, sm.confidence_lvl
                FROM speech_emotion_results sm
                WHERE sm.interview_id = %s AND sm.question_id = %s
            """
            cursor.execute(speech_emotion_query, [interview_id, question_id])
            sentiment_query_results = cursor.fetchall()

            question_response = {
                'question': question,
                'sentiment results': sentiment_query_results,
                'speech emotion results': sentiment_query_results
            }
            response_data.append(question_response)
    
    return JsonResponse(response_data, safe=False, status=200)


def speech_emotion_analysis(base64_audio_string):
    url = 'https://54.242.14.251/speech_emotion_analysis/'
    data = {'audio': base64_audio_string}
    response = requests.post(url, json=data, verify=False)

    if response.status_code == 200:
        return response.json()
    else:
        print('Error running speech emotion analysis with response code ', response.status_code)