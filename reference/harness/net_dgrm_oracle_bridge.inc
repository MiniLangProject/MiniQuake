void mq_Test_f(void) { Test_f(); }
void mq_Test_Poll(void) { Test_Poll(); }
void mq_Test2_f(void) { Test2_f(); }
void mq_Test2_Poll(void) { Test2_Poll(); }
qsocket_t *mq__Datagram_CheckNewConnections(void) { return _Datagram_CheckNewConnections(); }
void mq__Datagram_SearchForHosts(qboolean xmit) { _Datagram_SearchForHosts(xmit); }
qsocket_t *mq__Datagram_Connect(char *host) { return _Datagram_Connect(host); }
int mq_test_in_progress(void) { return testInProgress; }
int mq_test_poll_count(void) { return testPollCount; }
int mq_test2_in_progress(void) { return test2InProgress; }
int mq_net_landriverlevel(void) { return net_landriverlevel; }
void mq_set_net_landriverlevel(int value) { net_landriverlevel = value; }
int mq_my_driver_level(void) { return myDriverLevel; }
void mq_set_my_driver_level(int value) { myDriverLevel = value; }
