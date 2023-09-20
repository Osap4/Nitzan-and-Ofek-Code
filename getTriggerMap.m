%% Hunter analysis
% Ofek sapir


%% triger map:
rec_path = '/media/sil1/Data/Pogona Vitticeps/PV87/PV87_Hunter18_2022_12_15/Electrophys_2022-12-15_14-14-18';
rec = OERecording(rec_path);

behave_csv_path = '/media/sil1/Data/Pogona Vitticeps/PV87/PV87_Hunter18_2022_12_15/Arena_20221215_141217/left_20221215-141425.csv';
trig_map = getTriggerMap(behave_csv_path,rec);


function trigMap = getTriggerMap(behave_csv_path, rec)

% this function create a mat and a CSV that sync the triggers between the
% triggers in the behave_path and the triggers of the OErecording. 
% inputs: 
% * behave_CDV_path: the CSV file for one of the camares, including the
%   full path.
% * rec: OE recording.
% outputs:
%   * trig_map = mat with 3 colunms:(1) video timestamps, (2) time from 
%   start of video and (3) OE timestamps. 
% the function also saves the mat in a CSV on the filepath of the
% OErecording. 
% if there are differences between the the OE triggers and the video
% triggers count, the function will notify the user. 

% Load trigger data 
trig_path = rec.recordingDir;
trig = rec.getTrigger;

if size(trig{1},2) > 1
    trig = cell2mat(trig(1))';
elseif size(trig{1},2) == 0
    trig = cell2mat(trig(end-1))';
end
sz_trig_1 = size(trig,1);

% Load behavior data
behave = readmatrix(behave_csv_path); %upload the csv
behave = behave(:,1); % behavioral comp videos timestanps.
sz_behave = size(behave,1); % size od video triggers.
difference = diff(behave);  % diff (seconds)

% Adjust trigger data if needed
if sz_behave ~= sz_trig_1
    t_diff = diff(trig); %t_diff in ms
    row = find(t_diff >= 200);
    for i = 2:size(row,1)
        if sz_behave - 1 <= row(i) - row(i-1)
            trim_trig = trig(row(i-1)+1:row(i)+1,:);
            sz_trig_2 = size(trim_trig,1);
            if sz_trig_1 ~= sz_trig_2
                break;
            end
        end
    end
end

% Finding difference in trigger number between behavior and Openephys
d = abs(sz_behave - sz_trig_2);
d = d(1);
trig_diff = 'Diff in Trigger num = ' + string(d);
if d >= 1 % padds the ending with zeros
    behave = [behave;zeros(d,1)];
    difference = [difference;zeros(d,1)];
end

% Calculate time from start of video. (maybe will need to change later?)
timeFromZero = [0; cumsum(difference)];

% Create final matrix
mat = [behave, timeFromZero, trim_trig];

% Define variable names
variableNames = {'Behavior (sec)', 'TimeFromZero (sec)', 'OE Time (ms)'};

% Write the matrix to CSV with variable names
outputDir = fullfile(rec.recordingDir, 'Trigger Map');
mkdir(outputDir);
csvFilePath = fullfile(outputDir, 'trig_map.csv');
writetable(array2table(mat, 'VariableNames', variableNames), csvFilePath);

trigMap = mat;
disp(trig_diff)

end
