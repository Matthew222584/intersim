from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json
import random
from datetime import datetime
from ibm_watson import NaturalLanguageUnderstandingV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from ibm_watson.natural_language_understanding_v1 \
    import Features, CategoriesOptions

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
def getsentiment(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    username = request.GET.get('username')

        # Make sure username is passed in
    if not username:
        return JsonResponse({'message': 'Username is required', 'status': 'fail'}, status=400)

    # Check if user exists in the database
    if not user_exists(username):
        return JsonResponse({'message': 'User not found', 'status': 'fail'}, status=404)
    
    response = requests.post('http://3.144.9.248:8000/sentiment/', json={'text': text})

    emotion_dict = response['emotions']

    max_emotion = max(emotion_dict, key=emotion_dict.get)
    max_score = max(emotion_dict.values())

    # We don't need this thing yet for the skeletal

    query = """
        INSERT INTO question_answers ()
        VALUES (%s, %s, %s, %s, %s, %s, %s);
    """

    with connection.cursor() as cursor:
        cursor.execute(query, [response[],response[],response[])

    return JsonResponse({'status': 'success', 'data': rows})



