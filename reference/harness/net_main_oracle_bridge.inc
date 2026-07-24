void mq_NET_Listen_f(void) { NET_Listen_f(); }
void mq_MaxPlayers_f(void) { MaxPlayers_f(); }
void mq_NET_Port_f(void) { NET_Port_f(); }
void mq_PrintSlistHeader(void) { PrintSlistHeader(); }
void mq_PrintSlist(void) { PrintSlist(); }
void mq_PrintSlistTrailer(void) { PrintSlistTrailer(); }
void mq_Slist_Send(void) { Slist_Send(); }
void mq_Slist_Poll(void) { Slist_Poll(); }
int mq_listening(void) { return listening; }
void mq_set_listening(int value) { listening = value; }
int mq_slist_last_shown(void) { return slistLastShown; }
void mq_set_slist_start(double value) { slistStartTime = value; }
void mq_clear_poll_list(void) { pollProcedureList = NULL; }
int mq_poll_count(void)
{
    PollProcedure *item = pollProcedureList;
    int count = 0;
    while (item)
    {
        ++count;
        item = item->next;
        if (count > 128)
            return -1;
    }
    return count;
}
