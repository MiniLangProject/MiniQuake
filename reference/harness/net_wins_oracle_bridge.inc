int mq_PartialIPAddress(char *text, struct qsockaddr *address) { return PartialIPAddress(text, address); }
void mq_set_blocktime(double value) { blocktime = value; }
double mq_blocktime(void) { return blocktime; }
void mq_set_my_addr(unsigned long value) { myAddr = value; }
unsigned long mq_my_addr(void) { return myAddr; }
int mq_accept_socket(void) { return net_acceptsocket; }
void mq_set_accept_socket(int value) { net_acceptsocket = value; }
int mq_control_socket(void) { return net_controlsocket; }
int mq_broadcast_socket(void) { return net_broadcastsocket; }
void mq_set_broadcast_socket(int value) { net_broadcastsocket = value; }
struct qsockaddr *mq_broadcast_addr(void) { return &broadcastaddr; }
