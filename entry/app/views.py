from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from ibm_watson import NaturalLanguageUnderstandingV1
from ibm_watson.natural_language_understanding_v1 import Features, EmotionOptions
import requests

def user_exists(username):
    """Check if the user exists in the database."""
    user_exists_query = '''
        SELECT EXISTS (
            SELECT 1
            FROM users
            WHERE username = %s
        )
    '''
    with connection.cursor() as cursor:
        cursor.execute(user_exists_query, [username])
        user_exist_bool = cursor.fetchone()
        return user_exist_bool

@csrf_exempt
def getquestions(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    username = request.GET.get('username')
    num_questions = request.GET.get('num_questions')
    if not username or not num_questions:
        return JsonResponse({'message': 'Username and num_questions are required'}, status=400)

    username = str(username)
    num_questions = str(num_questions)
    if not user_exists(username):
        return JsonResponse({'message': 'User not found', 'status': 'fail'}, status=404)

    question_selection_query = """
        SELECT *
        FROM (
            SELECT question_id, question_content
            FROM questions
            ORDER BY RANDOM()
            LIMIT %s
        ) AS questions
        ORDER BY questions.question_id ASC;
    """
    with connection.cursor() as cursor:
        cursor.execute(question_selection_query, [num_questions])
        rows = cursor.fetchall()
        question_data = [{row[0]: row[1]} for row in rows]

    create_new_interview_query = """
        INSERT INTO interviews (username)
        VALUES (%s)
        RETURNING interview_id;
    """
    with connection.cursor() as cursor:
        cursor.execute(create_new_interview_query, [username])
        interview_id = cursor.fetchone()[0]

    return JsonResponse({'interview_id': interview_id, 'questions': question_data}, status=200)


def add_analysis_results(interview_id, question_id, analysis_type, emotion, percent):
    query = """
        INSERT INTO analysis_results (interview_id, question_id, analysis_type, emotion, percent)
        VALUES (%s, %s, %s, %s, %s);
    """
    with connection.cursor() as cursor:
        cursor.execute(query, [interview_id, question_id, analysis_type, emotion, percent])


def sentiment_analysis(input_text):
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

    return emotion_dict


def speech_emotion_analysis(base64_audio_string):
    url = 'https://34.239.249.255/speech_emotion_analysis/'
    data = {'audio': base64_audio_string}
    print("beginning speech emotion analysis")
    response = requests.post(url, json=data, verify=False)
    print("there's a response")
    if response.status_code == 200:
        return response.json()
    else:
        print('Error running speech emotion analysis with response code ', response.status_code)


@csrf_exempt
def postresponse(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    try:
        json_data = json.loads(request.body)
        username = json_data['username']
        interview_id = json_data['interview_id']
        question_id = json_data['question_id']
        user_text_response = json_data['question_answer']
        base64_audio_string = json_data['audio']
        base64_video_string = json_data['video']
    except KeyError as e:
        return JsonResponse({'message': f'Missing required parameter: {e}', 'status': 'fail'}, status=400)
    except json.JSONDecodeError:
        return JsonResponse({'message': 'Invalid JSON format', 'status': 'fail'}, status=400)
    
    sentiment_results = sentiment_analysis(user_text_response)
    for emotion, percentage in sentiment_results.items():
        add_analysis_results(interview_id, question_id, 'sentiment', emotion, round(percentage, 4))
    print("finish sentiment")

    speech_emotion_results = ""
    if (base64_audio_string):
        speech_emotion_results = speech_emotion_analysis(base64_audio_string)
        for emotion, percentage in speech_emotion_results.items():
            add_analysis_results(interview_id, question_id, 'speech_emotion', emotion, round(percentage, 4))

    insert_interview = """
        INSERT INTO user_responses (interview_id, question_id, text_response, audio_response, video_response_url)
        VALUES (%s, %s, %s, %s, %s);
    """
    with connection.cursor() as cursor:
        cursor.execute(insert_interview, [interview_id, question_id, user_text_response, base64_audio_string, base64_video_string])

    return JsonResponse({'status': 'success', 'sentiment': sentiment_results, 'speech_emotion': speech_emotion_results}, status=201)


def get_analysis_results(interview_id, question_id, analysis_type):
    with connection.cursor() as cursor:
        get_analysis_query = """
            SELECT emotion, percent
            FROM analysis_results
            WHERE interview_id = %s AND question_id = %s AND analysis_type = %s;
        """
        cursor.execute(get_analysis_query, [interview_id, question_id, analysis_type])

        return cursor.fetchall()

@csrf_exempt
def getfeedback(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    username = request.GET.get('username')
    interview_id = request.GET.get('interview_id')

    questions_and_answers_query = """
        SELECT ur.question_id, q.question_content, ur.text_response, ur.audio_response
        FROM user_responses ur
        INNER JOIN questions q ON q.question_id = ur.question_id
        WHERE ur.interview_id = %s
        ORDER BY ur.question_id ASC;
    """

    response_data = []
    with connection.cursor() as cursor:
        cursor.execute(questions_and_answers_query, [interview_id])
        asked_questions_info = cursor.fetchall()

        for question_info in asked_questions_info:
            question_id = question_info[0]
            question_content = question_info[1]
            text_response = question_info[2]
            audio_response = question_info[3]
            print(question_id, question_content, text_response)


            sentiment_results = get_analysis_results(interview_id, question_id, 'sentiment')
            speech_emotion_results = get_analysis_results(interview_id, question_id, 'speech_emotion')

            question_response = {
                'question_id': question_id,
                'question_content': question_content,
                'text_response': text_response,
                'audio_response': audio_response,
                'sentiment_results': sentiment_results,
                'speech_emotion_results': speech_emotion_results
            }

            response_data.append(question_response)
    
    return JsonResponse({'response_data': response_data}, status=200)


# Create your views here.
