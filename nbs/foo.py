import hyp3_sdk as sdk
import asf_search as asf
from config import hyp3_username, hyp3_password
from med_granules import med_granules



hyp3 = sdk.HyP3(username=hyp3_username, password=hyp3_password)
rtc_jobs = hyp3.find_jobs(name='cali_granules_all')
succeeded_jobs = rtc_jobs.filter_jobs(succeeded=True, running=False, failed=False)
print(f'Number of succeeded jobs: {len(succeeded_jobs)}')
failed_jobs = rtc_jobs.filter_jobs(succeeded=False, running=False, failed=True)
print(f'Number of failed jobs: {len(failed_jobs)}')
# rtc_jobs = hyp3.watch(rtc_jobs)

file_list = succeeded_jobs.download_files('/home1/08452/kaipak/corral-slice/datasets/hyp3_california_30m')
