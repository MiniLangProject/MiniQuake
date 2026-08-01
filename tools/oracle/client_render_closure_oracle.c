#include <stdint.h>
#include <stdio.h>
static void row(const char*n,uint64_t v){printf("{\"name\":\"%s\",\"value\":%llu}\n",n,(unsigned long long)v);}
int main(void){row("contract_fingerprint",0x95e2b295u);row("max_visedicts",256);row("max_temp_entities",64);row("beam_pool",24);row("beam_step",30);row("feature_bits",15);row("fixtures",24);return 0;}
