function is_feeder = feederCheck(trig_map, events_csv_path)

% Getting triggers timestamps and events
if isa(trig_map,"string") % if the trig_map is a path to the CSV:
    trig_map = readmatrix(trig_map);
    disp ("the variable is a path, taking data form the CSV")
elseif isa(trig_map,"double") % if its the mat
    disp ("the trig_map is a mat")
end 

E = readtable(events_csv_path);

% Selecting only the active feeder timestamp
E = E(strcmp(E.event, 'arena_command'),:);
E_hit = contains(E.value, '["dispense", "Feeder"]');
hit_positions = E_hit==1;
E_hit_timestamp = table2array(E(hit_positions,"time"));

% Matching the active feeder to the nearest trigger
B = trig_map(:,1);
result = false(size(B));
for i = 1:numel(B) - 1
    if any (E_hit_timestamp > B(i) & E_hit_timestamp < B(i+1))
        result(i) = true;
    end
end
values_in_B = B(result);
[~,pos] = intersect(B, values_in_B);

% Creating an array with the nearest triggers' timestamp from Openephys
F = zeros(size(pos, 1), 1);
for j = 1:size(pos)
    row = pos(j, 1);
    col = 3;
    F(j) = trig_map(row,col);
end

is_feeder = F;

end
