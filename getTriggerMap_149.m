%% Hunter analysis
% Ofek sapir


%% triger map:

function trigMap = getTriggerMap_149(behave_csv_path, rec)

% This function creates a mat and a CSV that sync the triggers between the
% triggers in the behave_path and the triggers of the OErecording.
% Inputs: 
% * behave_CSV_path: the CSV file of one of the cameras, including the
%   full path and the file name.
% * rec: OE recording.
% Outputs:
%   * trig_map = mat with 3 colunms:(1) video timestamps, (2) time from 
%     start of video and (3) OE timestamps. 
%   * the function also saves the mat in a CSV on the filepath of the
%     OErecording. 
% If there are differences between the the OE triggers and the video
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
behave = readmatrix(behave_csv_path); % upload the csv
behave = behave(2:end,2); % behavioral comp videos timestamps.
sz_behave = size(behave,1); % size of video triggers.
difference = diff(behave);  % diff (sec)

% Adjust trigger data if needed
if sz_behave ~= sz_trig_1
    t_diff = diff(trig); % t_diff (ms)
    big_diff = find(t_diff >= 1000);
    if size(big_diff,1) == 2
        trim_trig = trig(big_diff(1)+1:big_diff(2)+1,:);
        sz_trig_2 = size(trim_trig,1);
    else
        disp('Data Problem - too many gaps of over 2 sec')
        return
    end
end

% Finding difference in trigger number between behavior and Openephys
d = abs(sz_behave - sz_trig_2);
d = d(1);
trig_diff = 'Diff in Trigger num = ' + string(d);
if d >= 1 % adds the ending with zeros
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
