#!/bin/bash

USER=$1
DNS=$2
WORKDIR="/home/${USER}/.nezha-agent"
FILE_PATH="/home/${USER}/.s5"
CRON_S5="nohup ${FILE_PATH}/s5 -c ${FILE_PATH}/config.json >/dev/null 2>&1 &"
CRON_NEZHA="nohup ${WORKDIR}/start.sh >/dev/null 2>&1 &"
ALIST_PATH="/home/${USER}/domains/${DNS}"
CRON_ALIST="cd ${ALIST_PATH} && screen ./alist server >/dev/null 2>&1 &"
PM2_PATH="/home/${USER}/.npm-global/lib/node_modules/pm2/bin/pm2"
CRON_JOB="*/12 * * * * $PM2_PATH resurrect >> /home/${USER}/pm2_resurrect.log 2>&1"
REBOOT_COMMAND="@reboot pkill -kill -u ${USER} && $PM2_PATH resurrect >> /home/${USER}/pm2_resurrect.log 2>&1"
FANS_PATH="/home/${USER}/domains/fansMedalHelper"
CRON_FANS="cd ${FANS_PATH} && screen python main.py --auto >/dev/null 2>&1 &"

echo "检查并添加 crontab 任务"

if [ "$(command -v pm2)" == "/home/${USER}/.npm-global/bin/pm2" ]; then
  echo "已安装 pm2，并返回正确路径，启用 pm2 保活任务"
  (crontab -l | grep -F "$REBOOT_COMMAND") || (crontab -l; echo "$REBOOT_COMMAND") | crontab -
  (crontab -l | grep -F "$CRON_JOB") || (crontab -l; echo "$CRON_JOB") | crontab -
else
  echo "未安装pm2,开始检测crontab"
  if [ -e "${WORKDIR}/start.sh" ] && [ -e "${FILE_PATH}/config.json" ]; then
    echo "添加 nezha & socks5 的 crontab 重启任务"
    (crontab -l | grep -F "@reboot pkill -kill -u ${USER} && ${CRON_S5} && ${CRON_NEZHA}") || (crontab -l; echo "@reboot pkill -kill -u ${USER} && ${CRON_S5} && ${CRON_NEZHA}") | crontab -
    (crontab -l | grep -F "* * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") || (crontab -l; echo "*/12 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") | crontab -
    (crontab -l | grep -F "* * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") || (crontab -l; echo "*/12 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") | crontab -
  elif [ -e "${WORKDIR}/start.sh" ]; then
    echo "添加 nezha 的 crontab 重启任务"
    (crontab -l | grep -F "@reboot pkill -kill -u ${USER} && ${CRON_NEZHA}") || (crontab -l; echo "@reboot pkill -kill -u ${USER} && ${CRON_NEZHA}") | crontab -
    (crontab -l | grep -F "* * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") || (crontab -l; echo "*/12 * * * * pgrep -x \"nezha-agent\" > /dev/null || ${CRON_NEZHA}") | crontab -
  elif [ -e "${FILE_PATH}/config.json" ]; then
    echo "添加 socks5 的 crontab 重启任务"
    (crontab -l | grep -F "@reboot pkill -kill -u ${USER} && ${CRON_S5}") || (crontab -l; echo "@reboot pkill -kill -u ${USER} && ${CRON_S5}") | crontab -
    (crontab -l | grep -F "* * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") || (crontab -l; echo "*/12 * * * * pgrep -x \"s5\" > /dev/null || ${CRON_S5}") | crontab -
  else
    echo "未找到符合条件的crontab"
  fi
fi

if [ -e "${ALIST_PATH}/alist" ]; then
   echo "添加Alist重启任务"
   (crontab -l | grep -F "@reboot pkill -kill -u ${USER} && ${CRON_ALIST}") || (crontab -l; echo "@reboot pkill -kill -u ${USER} && ${CRON_ALIST}") | crontab -
   (crontab -l | grep -F "* * pgrep -x \"alist\" > /dev/null || ${CRON_ALIST}") || (crontab -l; echo "*/12 * * * * pgrep -x \"alsit\" > /dev/null || ${CRON_ALIST}") | crontab -
else
  echo "未安装Alist"
fi

if [ -e "${FANS_PATH}/main.py" ]; then
   echo "添加B站粉丝牌自动签到重启任务"
   (crontab -l | grep -F "@reboot pkill -kill -u ${USER} && ${CRON_FANS}") || (crontab -l; echo "@reboot pkill -kill -u ${USER} && ${CRON_FANS}") | crontab -
   (crontab -l | grep -F "* * pgrep -x \"python3.11\" > /dev/null || ${CRON_FANS}") || (crontab -l; echo "*/12 * * * * pgrep -x \"python3.11\" > /dev/null || ${CRON_FANS}") | crontab -
else
  echo "未安装B站粉丝牌自动签到"
fi 