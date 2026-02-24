from google import genai

# S3_Analyzer.py에 넣으셨던 본인의 API 키를 여기에 똑같이 넣어주세요
MY_API_KEY = "AIzaSyBDoTJxZJkiV7NoVwd6F5cpCU2hw3Z_ABY"
genai.configure(api_key=MY_API_KEY)

print("✅ 내 API 키로 사용할 수 있는 모델 목록:")
for m in genai.list_models():
    # 'generateContent'(텍스트 생성) 기능을 지원하는 모델만 출력
    if 'generateContent' in m.supported_generation_methods:
        print(m.name)