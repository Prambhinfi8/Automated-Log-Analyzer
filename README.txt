Automated Log Analyzer - Project Files
=====================================

📄 FILES:
- log_analyzer.sh : Shell script that analyzes system logs with colors and summary.
- README.txt      : This guide.

⚙️ USAGE:
1. Make the script executable:
   chmod +x log_analyzer.sh

2. Run it with a log file (default: /var/log/syslog):
   ./log_analyzer.sh
   OR
   ./log_analyzer.sh /path/to/your/logfile

🕒 CRON SETUP:
To run the analyzer daily at 9 AM:
1. Open crontab:
   crontab -e

2. Add this line (update paths accordingly):
   0 9 * * * /full/path/to/log_analyzer.sh > /home/YOUR_USERNAME/log_report.txt

3. Save and exit.

That's it!
