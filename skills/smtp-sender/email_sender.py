import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import json
import os
import mimetypes

current_path = os.path.realpath(__file__)
current_dir=os.path.dirname(current_path)
CONFIG_PATH = f"{current_dir}/smtp-config.json"

# Load SMTP configuration
def load_config():
    with open(CONFIG_PATH, 'r') as f:
        return json.load(f)

# Get MIME type for file
def get_mime_type(file_path):
    """根据文件扩展名获取正确的MIME类型"""
    mime_type, _ = mimetypes.guess_type(file_path)
    if mime_type:
        return mime_type.split('/')
    
    # 手动映射常见文件类型
    ext = os.path.splitext(file_path)[1].lower()
    mime_map = {
        '.pdf': ('application', 'pdf'),
        '.md': ('text', 'plain'),
        '.txt': ('text', 'plain'),
        '.docx': ('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document'),
        '.doc': ('application', 'msword'),
        '.xlsx': ('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        '.xls': ('application', 'vnd.ms-excel'),
        '.pptx': ('application', 'vnd.openxmlformats-officedocument.presentationml.presentation'),
        '.ppt': ('application', 'vnd.ms-powerpoint'),
        '.png': ('image', 'png'),
        '.jpg': ('image', 'jpeg'),
        '.jpeg': ('image', 'jpeg'),
        '.gif': ('image', 'gif'),
    }
    return mime_map.get(ext, ('application', 'octet-stream'))

# Send an email
def send_email(to_email, subject, body, html=False, body_file=None, attachments=[]):
    config = load_config()

    # Set up email server
    server = smtplib.SMTP_SSL(config['server'], config['port']) if config.get('useTLS') else smtplib.SMTP(config['server'], config['port'])
    server.login(config['username'], config['password'])

    # Prepare the email
    msg = MIMEMultipart()
    msg['From'] = config['emailFrom']
    msg['To'] = to_email
    msg['Subject'] = subject

    # Attach the body or read from body file
    if body_file:
        with open(body_file, 'r') as file:
            body_content = file.read()
        msg.attach(MIMEText(body_content, 'html' if html else 'plain'))
    else:
        msg.attach(MIMEText(body, 'html' if html else 'plain'))

    # Attach files with correct MIME types
    for file_path in attachments:
        if not os.path.exists(file_path):
            print(f"警告: 文件不存在: {file_path}")
            continue
            
        with open(file_path, 'rb') as attachment:
            file_name = os.path.basename(file_path)
            main_type, sub_type = get_mime_type(file_path)
            
            mime_part = MIMEBase(main_type, sub_type)
            mime_part.set_payload(attachment.read())
            encoders.encode_base64(mime_part)
            
            # 设置Content-Disposition头，确保文件名正确编码
            mime_part.add_header(
                'Content-Disposition', 
                f'attachment; filename="{file_name}"'
            )
            msg.attach(mime_part)
            print(f"  已附加: {file_name} ({main_type}/{sub_type})")

    # Send the email
    server.send_message(msg)
    server.quit()

# Example usage
if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Send an email via SMTP")
    parser.add_argument('--to', required=True, help="Recipient email address")
    parser.add_argument('--subject', required=True, help="Subject of the email")
    parser.add_argument('--body', help="Body text of the email")
    parser.add_argument('--body-file', help='Path to HTML or text file for email body')
    parser.add_argument('--html', action='store_true', help="Send as HTML email")
    parser.add_argument('--attachments', nargs='*', help="List of file paths to attach")

    args = parser.parse_args()

    if not args.body and not args.body_file:
        parser.error("Either --body or --body-file must be provided")

    send_email(
        to_email=args.to,
        subject=args.subject,
        body=args.body,
        body_file=args.body_file,
        html=args.html,
        attachments=args.attachments or []
    )
