function is_hit = hitCheck(trig_map, events_csv_path)

% this function...
% Inputs:
% * trig_map_csv_path / trig_map -
%   can get either the CSV path file or the mat that is the uotput of
%   getTriggerMap.

% Getting triggers timestamps and events
if isa(trig_map,"string") % if the trig_map is a path to the CSV:
    trig_map = readmatrix(trig_map_csv_path);
    disp ("the variable is a path, taking data form the CSV")
elseif isa(trig_map,"double") % if its the mat
    disp ("the trig_map is a mat")
end 

% reading the event file of the trial:
E = readtable(events_csv_path, 'Delimiter', ',', 'ReadVariableNames', true);
% Selecting only the hits timestamp
E = E(strcmp(E.event, 'screen_touch'),:);
E_hit = contains(E.value, '"is_hit": true');
hit_positions = E_hit==1;
E_hit_timestamp = table2array(E(hit_positions,"time")); 

% Matching the hit to the nearest trigger
B = trig_map(:,1); % taking the video triggers timestamps from behavioral comp
result = false(size(B));
for i = 1:numel(B) - 1
    if any (E_hit_timestamp > B(i) & E_hit_timestamp < B(i+1))
        result(i) = true;
    end
end
values_in_B = B(result);
[~,pos] = intersect(B, values_in_B);

% Creating an array with the nearest triggers' timestamp from Openephys
H = zeros(size(pos, 1), 1);
for j = 1:size(pos)
    row = pos(j, 1);
    col = 3;
    H(j) = trig_map(row,col);
end

is_hit = H;

end
