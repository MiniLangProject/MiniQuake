void mq_sys_win_reset_timer(void)
{
	curtime = 0.0;
	lastcurtime = 0.0;
	pfreq = 0.0;
	lowshift = 0;
	mq_oracle_sametimecount = 0;
	mq_oracle_oldtime = 0;
	mq_oracle_first = 1;
}

int mq_sys_win_lowshift(void) { return lowshift; }
double mq_sys_win_pfreq(void) { return pfreq; }
double mq_sys_win_curtime(void) { return curtime; }
void mq_sys_win_set_clock(double frequency_scale, int shift)
{
	pfreq = frequency_scale;
	lowshift = shift;
}
