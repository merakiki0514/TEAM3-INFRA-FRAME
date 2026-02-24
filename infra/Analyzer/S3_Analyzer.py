from google import genai

# 1. API 키 설정
MY_API_KEY = "AIzaSyBDoTJxZJkiV7NoVwd6F5cpCU2hw3Z_ABY"
client = genai.Client(api_key=MY_API_KEY)

# 2. 분석할 파일의 상대 경로 지정 (최상단 폴더 기준)
file_path = '../Live/ap-northeast-2/01-main-vpc/05. s3/main.tf'

try:
    with open(file_path, 'r', encoding='utf-8') as file:
        iac_code = file.read()
except FileNotFoundError:
    print(f"[{file_path}] 파일을 찾을 수 없습니다. 터미널 위치나 경로를 확인해주세요.")
    exit()

# 3. 프롬프트 작성
prompt = f"""
당신은 클라우드 보안 전문가입니다. 
아래 제공된 AWS Terraform 코드에서 보안 취약점을 분석해 주세요.
특히 S3 버킷의 퍼블릭 접근 권한 설정에 문제가 없는지 중점적으로 확인하고, 
발견된 문제점과 수정(Remediation) 가이드를 한국어로 명확하게 작성해 주세요.

[Terraform 코드]
{iac_code}
"""

# 4. Gemini 실행 (최신 모델 gemini-2.5-pro 사용)
print(f"🔍 [{file_path}] 코드를 최신 모델(gemini-2.5-pro)로 분석 중입니다...\n")
response = client.models.generate_content(
    model='gemini-2.5-flash',
    contents=prompt
)

# 5. 결과 출력 및 파일 저장
report_filename = "S3_security_report.txt"

# 터미널에도 간단히 출력하고
print(f"✅ 분석이 완료되었습니다. 결과가 [{report_filename}] 파일에 저장되었습니다.")

# 텍스트 파일로 결과를 내보내기 (저장)
with open(report_filename, 'w', encoding='utf-8') as report_file:
    report_file.write("================ [S3 IaC 보안 분석 리포트] ================\n\n")
    report_file.write(response.text)
    report_file.write("\n\n===========================================================")