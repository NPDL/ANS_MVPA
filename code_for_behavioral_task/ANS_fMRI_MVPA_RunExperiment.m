% INITIALIZE
% PsychJavaTrouble;
close all;
clear all;
InitializePsychSound(1);
% InitializeMatlabOpenAL;
KbName('UnifyKeyNames');
rand('twister',sum(100*clock))
commandwindow

%Get subject info
prompt = {'Subject Number';'Run #';'Cedrus/Keyboard'};
def = {'';'1,2,3,4';'Cedrus'};
answer = inputdlg(prompt, 'Experimental setup',1,def);
[subnum run inputMode] = deal(answer{:});
run_num=str2num(run);

%Paths
path_exp='/Users/Shipra/Documents/Experiments/ANS_fMRI_MVPA/ANS_fMRI_MVPA_';
path_stim=strcat(path_exp,'Stim/Run_',run,'/');
path_results=strcat(path_exp,'Results/');

%Filenames
fn_data_out_xls=strcat(path_results,subnum,'_Run_',run,'_',datestr(now, 'mmddyy'),'.xls');
fn_data_out_mat=strcat(path_results,subnum,'_Run_',run,'_',datestr(now, 'mmddyy'),'.mat');
fn_correct_answers=strcat(path_stim,'Run_',run,'_Correct_Answers.csv');
fn_stimulus_information=strcat(path_stim,'Run_',run,'_Stimulus_Information.csv');

%Durations
dur_delay=6;
dur_resp=3;
dur_rest=16;
dur_rest_aftertrial=6;

%(1) 4 TD Match List
%(2) 8 TD Match List
%(3) 16 TD Match List
%(4) 32 TD Match List
%(5) 4 Elem Match List
%(6) 8 Elem Match List
%(7) 16 Elem Match List
%(8) 32 Elem Match List

run_fmt=[...
    1,2,3,4,5,6,7,8,8,7,6,5,4,3,2,1,2,3,4,5,6,7,8,1,1,8,7,6,5,4,3,2;...
    3,4,5,6,7,8,1,2,2,1,8,7,6,5,4,3,4,5,6,7,8,1,2,3,3,2,1,8,7,6,5,4;...
    5,6,7,8,1,2,3,4,4,3,2,1,8,7,6,5,6,7,8,1,2,3,4,5,5,4,3,2,1,8,7,6;...
    7,8,1,2,3,4,5,6,6,5,4,3,2,1,8,7,8,1,2,3,4,5,6,7,7,6,5,4,3,2,1,8;...
    1,2,3,4,5,6,7,8,8,7,6,5,4,3,2,1,2,3,4,5,6,7,8,1,1,8,7,6,5,4,3,2;...
    3,4,5,6,7,8,1,2,2,1,8,7,6,5,4,3,4,5,6,7,8,1,2,3,3,2,1,8,7,6,5,4;...
    5,6,7,8,1,2,3,4,4,3,2,1,8,7,6,5,6,7,8,1,2,3,4,5,5,4,3,2,1,8,7,6;...
    7,8,1,2,3,4,5,6,6,5,4,3,2,1,8,7,8,1,2,3,4,5,6,7,7,6,5,4,3,2,1,8];

%Load stimulus information
stimulus_information=dlmread(fn_stimulus_information,'');

%Load correct answers
correct_answers=dlmread(fn_correct_answers,'');

%Load stimulus files
i=0;
for i=1:length(run_fmt(run_num,:)); %for each trial
    
    if run_fmt(run_num,i)~=0; %if not rest
    fn_stim_samp{i}=strcat(path_stim,'Trial_',num2str(i),'_Sample.wav');
    fn_stim_test{i}=strcat(path_stim,'Trial_',num2str(i),'_Test.wav');
    
    %Load sample
    [y_sample{i},freq_sample{i}] = audioread(char(fn_stim_samp{i}));
    dur_sample{i} = (length(y_sample{i})) ./ (freq_sample{i});
    chs_sample{i} = size(y_sample{i}',1); 
    try
        handle_sample{i} = PsychPortAudio('Open', [], [], 2, freq_sample{i}, chs_sample{i});
    catch
        fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq_sample{i});
        fprintf('Sound may sound a bit out of tune, ...\n\n');

        psychlasterror('reset');
        handle_sample{i} = PsychPortAudio('Open', [], [], 2, [], chs_sample{i});
    end
    PsychPortAudio('FillBuffer', handle_sample{i}, y_sample{i}');
    
    %Load test
    [y_test{i},freq_test{i}] = audioread(char(fn_stim_test{i}));
    dur_test{i} = (length(y_test{i})) ./ (freq_test{i});
    chs_test{i} = size(y_test{i}',1); 
    try
        handle_test{i} = PsychPortAudio('Open', [], [], 2, freq_test{i}, chs_test{i});
    catch
        fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq_test{i});
        fprintf('Sound may sound a bit out of tune, ...\n\n');

        psychlasterror('reset');
        handle_test{i} = PsychPortAudio('Open', [], [], 2, [], chs_test{i});
    end
    PsychPortAudio('FillBuffer', handle_test{i}, y_test{i}');
    
    dur_trial(i)=stimulus_information(i,6)+stimulus_information(i,7)+dur_resp+dur_delay;
    end
end

%----------------------------------------------------------------------------------SETUP OUTPUT FILE
output_data{1,1}='Run';
output_data{1,2}='Trial';
output_data{1,3}='Condition';
output_data{1,4}='Sample Number';
output_data{1,5}='Test Number';
output_data{1,6}='Match List';
output_data{1,7}='Congruence';
output_data{1,8}='Sample Duration';
output_data{1,9}='Test Duration';
output_data{1,10}='Correct Answer';
output_data{1,11}='Participant Response';
output_data{1,12}='Correct?';
output_data{1,13}='RT';
output_data{1,14}='RT Relative to Stim 2';
output_data{1,15}='Trigger Matlab';
output_data{1,16}='Trigger Cedrus';
output_data{1,17}='Rest Start';
output_data{1,18}='Sample Start';
output_data{1,19}='Delay Start';
output_data{1,20}='Test Start';
output_data{1,21}='Response Period Start';
output_data{1,22}='Response Period End';
output_data{1,23}='Trial End';
output_data{1,24}='Trial Rest End';

accumulated_time_error=0;

%----------------------------------------------------------------------------------WAIT FOR TRIGGER
if strcmp(inputMode,'Keyboard')==1;
    ts_trigger = GetSecs;
    ts_trigger_cedBox=nan;
    fprintf ('Send trigger\n')
    KbWait();
    fprintf ('Trigger received\n')
elseif strcmp(inputMode,'Cedrus')==1;
    cedrusopen
    cedrus.resettimer();
    cedrus.close()
    cedrusopen
    ts_trigger = GetSecs;
    fprintf ('Send trigger\n')
    while 1
        [b t p] = cedrus.waitpress(100000);
        if b == 6;
          break
        end
    end
    disp 'Trigger Received';
    ts_trigger_cedBox = cedrus.event{1}(2);
    %     cedrus.close(); 
end

%----------------------------------------------------------------------------------PLAY EXPERIMENT 
i=0;
for i=1:length(run_fmt(run_num,:));
    
    if run_fmt(run_num,i)==0; %rest
        ts_rest_start=GetSecs;
        
        fprintf('Rest\n');
        
        ts_sample_start=nan;
        ts_delay_start=nan;
        ts_test_start=nan;
        ts_resp_start=nan;
        ts_resp_end=nan;
        ts_admin=nan;
        ts_trial_end=nan;
        
        resp(i)=nan;
        cor_num(i)=nan;
        rt(i)=nan;
        rt_relative_to_stim2(i)=nan;
        
        output_data{i+1,1}=num2str(run_num);
        output_data{i+1,2}=num2str(i);
        output_data{i+1,3}=num2str(stimulus_information(i,1));
        output_data{i+1,4}=num2str(stimulus_information(i,2));
        output_data{i+1,5}=num2str(stimulus_information(i,3));
        output_data{i+1,6}=num2str(stimulus_information(i,4));
        output_data{i+1,7}=num2str(stimulus_information(i,5));
        output_data{i+1,8}=num2str(stimulus_information(i,6));
        output_data{i+1,9}=num2str(stimulus_information(i,7));
        output_data{i+1,10}=num2str(correct_answers(i));
        output_data{i+1,11}=num2str(resp(i));
        output_data{i+1,12}=num2str(cor_num(i));
        output_data{i+1,13}=num2str(rt(i));
        output_data{i+1,14}=num2str(rt_relative_to_stim2(i));
        output_data{i+1,15}=num2str(ts_trigger);
        output_data{i+1,16}=num2str(ts_trigger_cedBox);
        output_data{i+1,17}=num2str(ts_rest_start);
        output_data{i+1,18}=num2str(ts_sample_start);
        output_data{i+1,19}=num2str(ts_delay_start);
        output_data{i+1,20}=num2str(ts_test_start);
        output_data{i+1,21}=num2str(ts_resp_start);
        output_data{i+1,22}=num2str(ts_resp_end);
        output_data{i+1,23}=num2str(ts_trial_end);
        output_data{i+1,24}=num2str(ts_trial_rest_end);
        
        td_rest_admin=GetSecs-ts_rest_start; %How much time did the admin stuff during rest take
        
        dur_rest_adjust=dur_rest-td_rest_admin+accumulated_time_error;
        
        WaitSecs(dur_rest_adjust); %Wait for remainder of rest period not occupied by admin stuff
        accumulated_time_error=0;
        
    else %not rest
        ts_rest_start=nan;
        
        %Play sample
        ts_sample_start=GetSecs;
        PsychPortAudio('Start',handle_sample{i},1);
        WaitSecs(dur_sample{i});%check this
        
        %Delay
        ts_delay_start=GetSecs;
        WaitSecs(dur_delay);
        
        %Play test
        ts_test_start=GetSecs;
        PsychPortAudio('Start',handle_test{i},1);
        WaitSecs(dur_test{i});%check this
        ts_test_end=GetSecs;
        
        %Get Response
        ts_resp_start=GetSecs;
        if strcmp(inputMode,'Keyboard')==1; %Keyboard
            rt_relative_to_stim2(i)=nan;
            resp(i) = nan;
            rt(i) = nan;
            RestrictKeysForKbCheck([KbName('leftarrow'),KbName('rightarrow'),KbName('q')]);
            keyIsDown = 0;
            rt_start=GetSecs;
            while keyIsDown == 0 && GetSecs-rt_start < dur_resp;
                [keyIsDown, secs, keycode] = KbCheck();
                if find(keycode) == KbName('leftarrow');
                   resp(i) = 1;
                   rt(i) = secs-rt_start;
                   WaitSecs(dur_resp-rt(i)); %Wait for remainder of response period plus any of the .5 seconds of stim period that wasn't used by stim
                elseif find(keycode) == KbName('rightarrow');
                   resp(i) = 2;
                   rt(i) = secs-rt_start;
                   WaitSecs(dur_resp-rt(i)); %Wait for remainder of response period
                elseif find(keycode) == KbName('q'); %break
                   takebreak = 1;
                end
            end
            ts_resp_end=GetSecs;
        elseif strcmp(inputMode,'Cedrus')==1; %Cedrus

            %Do some side things while we wait for responses
                %write out data
                ts_admin=GetSecs;
                
                output_data{i+1,1}=num2str(run_num);
                output_data{i+1,2}=num2str(i);
                output_data{i+1,3}=num2str(stimulus_information(i,1));
                output_data{i+1,4}=num2str(stimulus_information(i,2));
                output_data{i+1,5}=num2str(stimulus_information(i,3));
                output_data{i+1,6}=num2str(stimulus_information(i,4));
                output_data{i+1,7}=num2str(stimulus_information(i,5));
                output_data{i+1,8}=num2str(stimulus_information(i,6));
                output_data{i+1,9}=num2str(stimulus_information(i,7));
                output_data{i+1,10}=num2str(correct_answers(i));
                
                output_data{i+1,15}=num2str(ts_trigger);
                output_data{i+1,16}=num2str(ts_trigger_cedBox);
                output_data{i+1,17}=num2str(ts_rest_start);
                output_data{i+1,18}=num2str(ts_sample_start);
                output_data{i+1,19}=num2str(ts_delay_start);
                output_data{i+1,20}=num2str(ts_test_start);
                output_data{i+1,21}=num2str(ts_resp_start);
                
                dlmcell(fn_data_out_xls,output_data); %This takes a really freaking long time to do; doing it here so that it gets done on every trial but doesn't take up additional time at the end

                %stop and close audio files
                PsychPortAudio('Stop',handle_sample{i}); %stop stim 1
                PsychPortAudio('Close',handle_sample{i}); %close stim 1
                PsychPortAudio('Stop',handle_test{i}); %stop stim 2
                PsychPortAudio('Close',handle_test{i}); %close stim 2

                td_admin=GetSecs-ts_admin;

                WaitSecs(dur_resp-td_admin); %Wait duration of response period to collect responses minus any time that admin stuff took

            ts_resp_end=GetSecs; %Mark that the response period ended
            dur_resp_window_start=ts_test_start-ts_trigger; %start of response window
            dur_resp_window_end=ts_resp_end-ts_trigger; %end of response window

            cedrus.getpress; %Get all button presses from when cedrus box was opened

            cedresps.(strcat('x',num2str(i))) = cedrus;

            if isempty(cedresps.(strcat('x',num2str(i))).event)==0;
               c=0;
               for c=1:size(cedresps.(strcat('x',num2str(i))).event,2);
                   ced_rts(c) = cedresps.(strcat('x',num2str(i))).event{c}(2);
                   ced_resps(c) = cedresps.(strcat('x',num2str(i))).event{c}(1);
               end
               if isempty(find(ced_rts(:)>(dur_resp_window_start*1000) & ced_rts(:)<(dur_resp_window_end*1000)))==1; %any events during response window?
                  resp(i) = nan; 
                  rt_relative_to_stim2(i)=nan;
                  rt(i) = nan;
               else
                  rt(i) = ced_rts(find(ced_rts(:)>(dur_resp_window_start*1000)&ced_rts(:)<(dur_resp_window_end*1000),1));
                  rt_relative_to_stim2(i)=double(rt(i))-((ts_test_end-ts_trigger)*1000);
                  resp(i) = ced_resps(find(ced_rts(:)>(dur_resp_window_start*1000)&ced_rts(:)<(dur_resp_window_end*1000),1));
               end 
            else
               resp(i) = nan; 
               rt(i) = nan;
            end
        end

        if resp(i)==correct_answers(i);
            correct{i}='Correct';
            cor_num(i)=1;
        else
            correct{i}='Incorrect';
            cor_num(i)=0;
        end

        if strcmp(inputMode,'Keyboard')==1; %Keyboard
            fprintf('Block %d; %s; RT %f\n',i,correct{i},rt(i));
        elseif strcmp(inputMode,'Cedrus')==1; %Cedrus
            fprintf('Block %d; %s; RT %f\n',i,correct{i},rt_relative_to_stim2(i));
        end
        
        %Write out remaining data
        output_data{i+1,11}=num2str(resp(i));
        output_data{i+1,12}=num2str(cor_num(i));
        output_data{i+1,13}=num2str(rt(i));
        output_data{i+1,14}=num2str(rt_relative_to_stim2(i));
        
        output_data{i+1,22}=num2str(ts_resp_end);
        ts_trial_end=GetSecs;
        output_data{i+1,23}=num2str(ts_trial_end);
        
        accumulated_time_error=(dur_trial(i)-(ts_trial_end-ts_sample_start)); %trials may actually be slightly shorter than they should, so need to add back time to rest
        WaitSecs(dur_rest_aftertrial-accumulated_time_error);
        ts_trial_rest_end=GetSecs;
        output_data{i+1,24}=num2str(ts_trial_rest_end);
    end
    
end

cedrus.close();

output_data{i+1,1}=num2str(run_num);
output_data{i+1,2}=num2str(i);
output_data{i+1,3}=num2str(stimulus_information(i,1));
output_data{i+1,4}=num2str(stimulus_information(i,2));
output_data{i+1,5}=num2str(stimulus_information(i,3));
output_data{i+1,6}=num2str(stimulus_information(i,4));
output_data{i+1,7}=num2str(stimulus_information(i,5));
output_data{i+1,8}=num2str(stimulus_information(i,6));
output_data{i+1,9}=num2str(stimulus_information(i,7));
output_data{i+1,10}=num2str(correct_answers(i));
output_data{i+1,11}=num2str(resp(i));
output_data{i+1,12}=num2str(cor_num(i));
output_data{i+1,13}=num2str(rt(i));
output_data{i+1,14}=num2str(rt_relative_to_stim2(i));
output_data{i+1,15}=num2str(ts_trigger);
output_data{i+1,16}=num2str(ts_trigger_cedBox);
output_data{i+1,17}=num2str(ts_rest_start);
output_data{i+1,18}=num2str(ts_sample_start);
output_data{i+1,19}=num2str(ts_delay_start);
output_data{i+1,20}=num2str(ts_test_start);
output_data{i+1,21}=num2str(ts_resp_start);
output_data{i+1,22}=num2str(ts_resp_end);
output_data{i+1,23}=num2str(ts_trial_end);
output_data{i+1,24}=num2str(ts_trial_rest_end);

dlmcell(fn_data_out_xls,output_data);
save(fn_data_out_mat);
close all
clear all