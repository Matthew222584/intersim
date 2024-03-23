from django.shortcuts import render
from ibm_watson import NaturalLanguageUnderstandingV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from ibm_watson.natural_language_understanding_v1 \
    import Features, EmotionOptions

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

    # print(json.dumps(response, indent=2))
    emotion_dict = response["emotion"]["document"]["emotion"]
    max_emotion = max(emotion_dict, key=emotion_dict.get)
    max_score = max(emotion_dict.values())
    print(emotion_dict)
    print(max_emotion, max_score)
    return emotion_dict

@csrf_exempt
def sentiment(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    json_data = json.loads(request.body)
    text = json_data['text']
    return_dict = sentimentAPI(text)

    return JsonResponse({return_dict})
