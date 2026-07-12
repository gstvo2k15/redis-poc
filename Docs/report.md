The IIS access logs were reviewed for the reported incident window.

The following observations were made:

Throughout the analysed period, the IIS logs show continuous HTTP activity. Requests continued to be processed and no HTTP 503 (Service Unavailable), 502 (Bad Gateway) or 504 (Gateway Timeout) responses were found.
Between 2026-07-06 04:30:38 UTC and 2026-07-06 06:14:29 UTC, repeated requests to the Paygate application returned HTTP 500 (Internal Server Error). 

Examples include:
2026-07-06 04:30:38 GET /Paygate/Account/Login ... 500
2026-07-06 04:42:11 GET /Paygate/ ... 500
2026-07-06 05:57:43 GET /Paygate/ ... 500
2026-07-06 06:14:29 GET /Paygate/ ... 500
Successful responses were subsequently observed from 06:29:22 UTC, for example:
2026-07-06 06:29:22 GET /Paygate/ ... 200
2026-07-06 06:29:22 GET /Paygate/Account/GetSessionTimeout ... 200
2026-07-06 06:29:22 GET /Paygate/account/getlocalisationresource ... 200


Conclusion

Based solely on the IIS access logs, there is no evidence that IIS stopped accepting or processing HTTP requests during the analysed period, as no HTTP 503 responses or interruption in request logging were observed.
The logs do provide evidence that the Paygate application was returning HTTP 500 responses for a sustained period before later returning HTTP 200 responses.

According to the operational timeline, the issue was not resolved after the first IIS restart but only after the second restart. The IIS access logs alone cannot determine which restart restored the service, nor can they identify whether the recovery resulted from an IIS restart, an application pool recycle, or an application-level recovery. Correlation with Windows Event Logs (WAS/W3SVC/System) and application logs is required to establish the exact recovery event.







The IIS access logs do not indicate an IIS infrastructure failure. Instead, they show that IIS continued to process requests while the Paygate application consistently returned HTTP 500 (Internal Server Error) responses. This indicates that the failure originated within the application or one of its runtime dependencies rather than the IIS web service itself. The precise root cause cannot be determined from IIS access logs alone and requires correlation with the Windows Application/System Event Logs and the Paygate application logs.