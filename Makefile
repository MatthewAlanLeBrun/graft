SHELL = /bin/sh

DETECTER=/home/malb/Workspace/detecter
EBIN=/home/malb/Workspace/graft/_build/dev/lib/graft/ebin
HML=/home/malb/Workspace/graft/monitors/hml

build_detecter: 
	cd $(DETECTER) && make clean && make compile

compile_hml:
	cd $(DETECTER) && erl +S 4 +SDcpu 2 +P 134217727 -pa ebin/ -eval 'code:ensure_modules_loaded([ascii_writer,async_mon,async_tracer_test,build,client,collector,common,csv_writer,distr,driver,echo_protocol,events,evm_tracer,gen_file_poller,gen_file_poller_impl,gen_looper,gen_looper_impl,hml_eval,hml_lexer,hml_lint,hml_parser,launcher,log,log_eval,log_lexer,log_parser,log_poller,log_tracer,main,master,monitor,opts,server,slave,stats,system,trace_lib,tracer,tracer_monitor,util,weaver]), hml_eval:compile("$(HML)/$(FILE).hml", [{outdir, "ebin"}, v]), halt().'

compile_hml_w_erl:
	cd $(DETECTER) && erl +S 4 +SDcpu 2 +P 134217727 -pa ebin/ -eval 'code:ensure_modules_loaded([ascii_writer,async_mon,async_tracer_test,build,client,collector,common,csv_writer,distr,driver,echo_protocol,events,evm_tracer,gen_file_poller,gen_file_poller_impl,gen_looper,gen_looper_impl,hml_eval,hml_lexer,hml_lint,hml_parser,launcher,log,log_eval,log_lexer,log_parser,log_poller,log_tracer,main,master,monitor,opts,server,slave,stats,system,trace_lib,tracer,tracer_monitor,util,weaver]), hml_eval:compile("$(HML)/$(FILE).hml", [{outdir, "ebin"}, v, erl]), halt().'
	cp $(DETECTER)/ebin/$(FILE).erl ./monitors/

load:
	cp $(DETECTER)/ebin/*.beam $(EBIN)/
	
load_custom_mons:
	cp ./monitors/*.beam $(EBIN)/
