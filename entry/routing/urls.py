"""
URL configuration for routing project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
<<<<<<< HEAD

urlpatterns = [
    path('admin/', admin.site.urls),
=======
from app import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('getquestions/', views.getquestions, name='getquestions'),
    path('postresponse/', views.postresponse, name='postresponse'),
    path('getfeedback/', views.getfeedback, name='getfeedback'),
    path('post_speech_emotion_results/', views.post_speech_emotion_results, name='post_speech_emotion_results')
>>>>>>> 797bbe22f7a06d28fce8ac62606394ebc5730952
]
