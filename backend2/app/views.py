from django.shortcuts import render
from ibm_watson import NaturalLanguageUnderstandingV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from ibm_watson.natural_language_understanding_v1 \
    import Features, EmotionOptions
from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
import json

from os.path import join, dirname
from ibm_watson import SpeechToTextV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from django.core.files.storage import FileSystemStorage

from fastapi import File, UploadFile
from modelscope.pipelines import pipeline
from modelscope.utils.constant import Tasks
import numpy as np
import base64

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
    # max_emotion = max(emotion_dict, key=emotion_dict.get)
    # max_score = max(emotion_dict.values())

    return emotion_dict

@csrf_exempt
def sentiment(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    
    json_data = json.loads(request.body)
    text = json_data['text']
    print("testing ", text)
    return_dict = sentimentAPI(text)

    return JsonResponse({'emotions': return_dict})

def speechToTextAPI(filepath):
    authenticator = IAMAuthenticator('pIG-F8xSZWLOaYwiZDIe0-ITjWw7Rk8M7c9Vzqq9bi8s')
    speech_to_text = SpeechToTextV1(
        authenticator=authenticator
    )

    speech_to_text.set_service_url('https://api.au-syd.speech-to-text.watson.cloud.ibm.com/instances/8ec4f5a4-43d4-4866-a13a-1b11d1a7feb0')

    with open(filepath, 'rb') as audio_file:
        speech_recognition_results = speech_to_text.recognize(audio=audio_file).get_result()
    transcript = speech_recognition_results["results"][0]['alternatives'][0]['transcript']
    return {'transcript': transcript}

@csrf_exempt
def speechToText(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    uploaded_file = request.FILES.get('file')
    fs = FileSystemStorage()
    filename = fs.save(uploaded_file.name, uploaded_file)
    path = fs.path(filename)
    return_dict = speechToTextAPI(path)

    return JsonResponse(return_dict)

mapper = ["angry", "disgust", "fear", "happy",
          "neutral", "other", "sad", "surprised", "unknown"]

inference_pipeline = pipeline(
    task=Tasks.emotion_recognition,
    model="iic/emotion2vec_base_finetuned", model_revision="v2.0.4")

@csrf_exempt
def emotionRecognition(request):
    json_data = json.loads(request.body)
    base64_audio_text = json_data['audio']
    audio_bytes = base64.b64decode(base64_audio_text)

    print("got here1")

    rec_result = inference_pipeline(
        audio_bytes, output_dir="./outputs", granularity="utterance", extract_embedding=False)
    max_emotion_score = np.argmax(rec_result[0]["scores"])

    return_dict = {
        "emotion": mapper[max_emotion_score],
        "confidence":rec_result[0]["scores"][max_emotion_score]
    }

    return JsonResponse(return_dict)
