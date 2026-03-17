#!/usr/bin/env python3
"""
带实时进度反馈的邮件发送工具
"""

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import json
import os
import sys
import argparse
from datetime import datetime
import mimetypes

CONFIG_PATH = '/root/.openclaw/workspace/skills/smtp-sender/smtp-config.json'

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

def load_config():
    """加载SMTP配置"""
    with open(CONFIG_PATH, 'r') as f:
        return json.load(f)

def send_email_with_progress(to_email, subject, body, attachments=None, body_file=None):
    """发送邮件并显示实时进度"""
    
    print(f"\n{'='*60}")
    print(f"📧 邮件发送任务")
    print(f"{'='*60}")
    
    # 加载配置
    print("[1/5] 加载SMTP配置...", end=" ", flush=True)
    try:
        config = load_config()
        print(f"✅ ({config['emailFrom']})")
    except Exception as e:
        print(f"❌ 失败: {e}")
        return False
    
    # 创建邮件
    print("[2/5] 创建邮件内容...", end=" ", flush=True)
    try:
        msg = MIMEMultipart()
        msg['From'] = config['emailFrom']
        msg['To'] = to_email
        msg['Subject'] = subject
        
        # 添加正文
        if body_file and os.path.exists(body_file):
            with open(body_file, 'r', encoding='utf-8') as f:
                body = f.read()
        msg.attach(MIMEText(body, 'plain'))
        print("✅")
    except Exception as e:
        print(f"❌ 失败: {e}")
        return False
    
    # 添加附件
    attached_files = []
    if attachments:
        print(f"[3/5] 添加附件 ({len(attachments)}个)...")
        for i, filepath in enumerate(attachments, 1):
            filename = os.path.basename(filepath)
            print(f"      [{i}/{len(attachments)}] {filename}...", end=" ", flush=True)
            
            if not os.path.exists(filepath):
                print("❌ 文件不存在")
                continue
            
            try:
                with open(filepath, 'rb') as f:
                    main_type, sub_type = get_mime_type(filepath)
                    mime_part = MIMEBase(main_type, sub_type)
                    mime_part.set_payload(f.read())
                    encoders.encode_base64(mime_part)
                    # 使用RFC 2231编码处理中文文件名
                    from email.header import Header
                    mime_part.add_header('Content-Disposition', 'attachment', filename=('utf-8', '', filename))
                    msg.attach(mime_part)
                size_kb = os.path.getsize(filepath) // 1024
                print(f"✅ ({size_kb}KB, {main_type}/{sub_type})")
                attached_files.append((filename, size_kb))
            except Exception as e:
                print(f"❌ 失败: {e}")
    else:
        print("[3/5] 添加附件... ✅ (无附件)")
    
    # 连接SMTP
    print("[4/5] 连接SMTP服务器...", end=" ", flush=True)
    try:
        server = smtplib.SMTP_SSL(config['server'], config['port'])
        server.login(config['username'], config['password'])
        print(f"✅ ({config['server']}:{config['port']})")
    except Exception as e:
        print(f"❌ 失败: {e}")
        return False
    
    # 发送邮件
    print("[5/5] 发送邮件...", end=" ", flush=True)
    try:
        server.send_message(msg)
        server.quit()
        print("✅")
    except Exception as e:
        print(f"❌ 失败: {e}")
        return False
    
    # 完成汇总
    print(f"\n{'='*60}")
    print(f"✅ 邮件发送成功!")
    print(f"{'='*60}")
    print(f"收件人: {to_email}")
    print(f"主题: {subject}")
    print(f"附件数: {len(attached_files)}个")
    total_size = sum(size for _, size in attached_files)
    print(f"总大小: {total_size}KB")
    print(f"发送时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*60}\n")
    
    return True

def main():
    parser = argparse.ArgumentParser(description='发送邮件（带进度反馈）')
    parser.add_argument('--to', required=True, help='收件人邮箱')
    parser.add_argument('--subject', required=True, help='邮件主题')
    parser.add_argument('--body', default='', help='邮件正文')
    parser.add_argument('--body-file', help='正文文件路径')
    parser.add_argument('--attachments', nargs='*', help='附件文件列表')
    
    args = parser.parse_args()
    
    success = send_email_with_progress(
        to_email=args.to,
        subject=args.subject,
        body=args.body,
        attachments=args.attachments,
        body_file=args.body_file
    )
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
