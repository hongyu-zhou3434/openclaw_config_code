#!/usr/bin/env python3
"""
任务执行监控工具 - 实时显示任务进度和状态
"""

import subprocess
import sys
import time
import json
import os
from datetime import datetime
from pathlib import Path

class TaskMonitor:
    def __init__(self, task_name, log_file=None):
        self.task_name = task_name
        self.log_file = log_file or f"/tmp/task_{task_name}.log"
        self.status_file = f"/tmp/task_{task_name}.status"
        self.start_time = None
        self.end_time = None
        
    def start(self):
        """开始任务监控"""
        self.start_time = time.time()
        self._save_status("running", "任务开始执行")
        print(f"\n{'='*60}")
        print(f"🚀 任务启动: {self.task_name}")
        print(f"{'='*60}")
        print(f"开始时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"日志文件: {self.log_file}")
        print(f"{'='*60}\n")
        
    def log(self, message, level="INFO"):
        """记录日志"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_line = f"[{timestamp}] [{level}] {message}\n"
        
        # 写入日志文件
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(log_line)
        
        # 同时输出到控制台
        print(log_line.strip())
        
    def progress(self, current, total, message=""):
        """显示进度"""
        percentage = (current / total) * 100 if total > 0 else 0
        bar_length = 40
        filled = int(bar_length * current / total) if total > 0 else 0
        bar = '█' * filled + '░' * (bar_length - filled)
        
        status = f"\r[{bar}] {percentage:.1f}% ({current}/{total}) {message}"
        sys.stdout.write(status)
        sys.stdout.flush()
        
        if current >= total:
            print()  # 换行
            
    def step(self, step_num, total_steps, description):
        """记录步骤开始"""
        self.log(f"步骤 [{step_num}/{total_steps}]: {description}")
        self._save_status("running", f"执行步骤 {step_num}/{total_steps}: {description}")
        
    def step_complete(self, step_num, total_steps, result="成功"):
        """记录步骤完成"""
        self.log(f"步骤 [{step_num}/{total_steps}] 完成: {result}", "SUCCESS")
        
    def complete(self, status="success", message="任务完成"):
        """完成任务"""
        self.end_time = time.time()
        duration = self.end_time - self.start_time if self.start_time else 0
        
        self._save_status(status, message, duration)
        
        print(f"\n{'='*60}")
        if status == "success":
            print(f"✅ 任务完成: {self.task_name}")
        else:
            print(f"❌ 任务失败: {self.task_name}")
        print(f"{'='*60}")
        print(f"结束时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"执行耗时: {duration:.2f} 秒")
        print(f"状态: {message}")
        print(f"{'='*60}\n")
        
    def error(self, error_message):
        """记录错误"""
        self.log(error_message, "ERROR")
        self._save_status("error", error_message)
        
    def _save_status(self, status, message, duration=None):
        """保存状态到文件"""
        data = {
            "task_name": self.task_name,
            "status": status,
            "message": message,
            "timestamp": datetime.now().isoformat(),
            "duration": duration
        }
        with open(self.status_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            
    def get_status(self):
        """获取当前状态"""
        if os.path.exists(self.status_file):
            with open(self.status_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        return None

def run_command_with_monitor(cmd, task_name, show_output=True):
    """运行命令并实时监控输出"""
    monitor = TaskMonitor(task_name)
    monitor.start()
    
    try:
        monitor.log(f"执行命令: {cmd}")
        
        # 执行命令并捕获输出
        process = subprocess.Popen(
            cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )
        
        # 实时输出
        output_lines = []
        for line in process.stdout:
            line = line.strip()
            output_lines.append(line)
            if show_output:
                monitor.log(line)
        
        # 等待完成
        return_code = process.wait()
        
        if return_code == 0:
            monitor.complete("success", "命令执行成功")
            return True, output_lines
        else:
            monitor.complete("failed", f"命令执行失败 (返回码: {return_code})")
            return False, output_lines
            
    except Exception as e:
        monitor.error(f"执行异常: {str(e)}")
        monitor.complete("error", str(e))
        return False, []

def check_task_status(task_name):
    """检查任务状态"""
    status_file = f"/tmp/task_{task_name}.status"
    if os.path.exists(status_file):
        with open(status_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    return None

def list_active_tasks():
    """列出所有活动任务"""
    tasks = []
    for f in os.listdir('/tmp'):
        if f.startswith('task_') and f.endswith('.status'):
            task_name = f[5:-7]  # 去掉前缀和后缀
            status = check_task_status(task_name)
            if status:
                tasks.append(status)
    return tasks

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='任务监控工具')
    parser.add_argument('action', choices=['run', 'status', 'list'], help='操作')
    parser.add_argument('--task', help='任务名称')
    parser.add_argument('--cmd', help='要执行的命令')
    
    args = parser.parse_args()
    
    if args.action == 'run':
        if not args.cmd or not args.task:
            print("错误: --task 和 --cmd 参数必须提供")
            sys.exit(1)
        success, output = run_command_with_monitor(args.cmd, args.task)
        sys.exit(0 if success else 1)
        
    elif args.action == 'status':
        if not args.task:
            print("错误: --task 参数必须提供")
            sys.exit(1)
        status = check_task_status(args.task)
        if status:
            print(json.dumps(status, ensure_ascii=False, indent=2))
        else:
            print(f"未找到任务: {args.task}")
            
    elif args.action == 'list':
        tasks = list_active_tasks()
        if tasks:
            print(f"\n活动任务列表 ({len(tasks)}个):")
            print("-" * 60)
            for task in tasks:
                print(f"任务: {task['task_name']}")
                print(f"状态: {task['status']}")
                print(f"消息: {task['message']}")
                print(f"时间: {task['timestamp']}")
                if task.get('duration'):
                    print(f"耗时: {task['duration']:.2f}秒")
                print("-" * 60)
        else:
            print("没有活动任务")
