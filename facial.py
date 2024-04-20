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

def getfacial(request):
    if request.method != 'GET':
        return HttpResponse(status=404)  

    video_path = find_file("base64.online.txt")
   
    response = {}

    arrived = False
    with open(video_path, "r") as file:
        base64_data = file.read()
   
    video_data = base64.b64decode(base64_data + "==")

    # Write video data to a file
    with open("video.mp4", "wb") as f:
         f.write(video_data)

    # Open video file
    cap = cv2.VideoCapture("video.mp4")
 
    vid = cv2.VideoCapture(find_file("video.mp4"))
    interval_seconds = 1  # Interval in seconds
    success, image = vid.read()

    count = 0
    frame_rate = int(vid.get(cv2.CAP_PROP_FPS))
    interval_frames = int(frame_rate * interval_seconds)
    emotion_list = []
    to_df = {}

    if not vid.isOpened():
       response = {}
       response['facial analysis'] = [str(video_path), str(success), find_file("video.mp4")]
       return JsonResponse(response)

    while success:    
      image_name = 'frame%d.jpg' % count
      cv2.imwrite(image_name, image)
      objs_instance = DeepFace.analyze(img_path = image_name, actions = ['emotion'],)
      emotion_list.append(objs_instance[0]['dominant_emotion'])
      os.remove(image_name)
      success, image = vid.read()
      count += interval_frames
      vid.set(cv2.CAP_PROP_POS_FRAMES, count)
   
    os.remove(find_file("video.mp4"))
    to_df = dict(enumerate(emotion_list))
    response['facial analysis'] = [to_df]

    return JsonResponse(response)