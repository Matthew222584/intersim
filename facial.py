from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt
from deepface import DeepFace
import os
import cv2
import json
import base64
import ffmpeg

def find_file(filename, search_path='/'):
    for root, dirs, files in os.walk(search_path):
        if filename in files:
            return os.path.join(root, filename)
    return None

def actual_analysis(interview_id, question_id, video_data):
    print("starting thread")

    with open("video.mp4", "wb") as f:
         f.write(video_data)

    cap = cv2.VideoCapture("video.mp4")
    vid = cv2.VideoCapture(find_file("video.mp4"))
    interval_seconds = 1  # Interval in seconds
    success, image = vid.read()

    count = 0
    frame_rate = int(vid.get(cv2.CAP_PROP_FPS))
    interval_frames = int(frame_rate * interval_seconds)
    total_seconds = 0
    emotion_response = defaultdict(int)

    if not vid.isOpened():
       response = {}
       response['facial analysis'] = [str(video_path), str(success),>
       return JsonResponse({'status':'fail'})

    while success:
      image_name = 'frame%d.jpg' % count
      cv2.imwrite(image_name, image)
      objs_instance = DeepFace.analyze(img_path = image_name, action>
      total_seconds += 1
      emotion_response[objs_instance[0]['dominant_emotion']] += 1
      os.remove(image_name)
      success, image = vid.read()
      count += interval_frames
      vid.set(cv2.CAP_PROP_POS_FRAMES, count)

    os.remove(find_file("video.mp4"))

    for emotion, value in emotion_response.items():
        emotion_response[emotion] = value / total_seconds

    url = 'https://18.220.90.225/post_facial_results/'
    sending_result = {'response': emotion_response, 'interview_id':i>
    req_response = requests.post(url, json=sending_result, verify=Fa>
    print("sent with response of :", req_response)
   
@csrf_exempt
def getfacial(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
  
    json_data = json.loads(request.body)
    video_string = json_data['video']
    interview_id = json_data['interview_id']
    question_id = json_data['question_id']
    arrived = False
    video_data = base64.b64decode(video_string + "==")
    
    print("got data")

    thread = threading.Thread(target=actual_analysis, args=(intervie>
    thread.start()

    return JsonResponse({'status':'success'})
