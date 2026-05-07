function n_scribes = calc_schism_scribes(param)
% Calculate the # of scribes for SCHISM model
%
%% Syntax
% n_scribes = calc_schism_scribes(param);
%
%% Description
% n_scribes = calc_schism_scribes(param) calculates the # of scribes based on param.nml.
%
%% Examples
% param = 'schism-master\sample_inputs\param.nml';
% n_scribes = calc_schism_scribes(param);
%
%% Input Arguments
% param - param.nml; char
%       the filepath of "param.nml" file.
%
%% Author Info
% Created by Wenfan Wu, Virginia Institute of Marine Science in 2026.
% Last Updated on 7 May 2026.
% Email: wwu@vims.edu
%
% See also: read_schism_nml

%% Calculate the # of scribes
% read paran.nml flags
config = read_schism_nml(param);

% iof_* groups in param.nml (sed2d is excluded)
iof_groups = {'iof_hydro', 'iof_wwm', 'iof_gen', 'iof_age', 'iof_sed', 'iof_eco', 'iof_fib', 'iof_ice', 'iof_ana', ...  % According to the comments
    'iof_icm_core', 'iof_icm_silica', 'iof_icm_zb', 'iof_icm_ph', 'iof_icm_srm', ...  % 3D
    'iof_icm_sav', 'iof_icm_marsh', 'iof_icm_sfm', 'iof_icm_ba', 'iof_icm_clam', ... % 2D
    'iof_cos'}; % 3D

n_scribes = 1; % base value for all 2D variables
for ii = 1:numel(iof_groups)
    gname = iof_groups{ii};
    if isfield(config, gname)
        n_vals = numel(config.(gname));  % # of valid flags
        switch gname
            case {'iof_icm_core', 'iof_icm_silica', 'iof_icm_zb', 'iof_icm_ph', 'iof_icm_srm', 'iof_cos'}
                scribe_m = ones(1,n_vals);
            case {'iof_icm_sav', 'iof_icm_marsh', 'iof_icm_sfm', 'iof_icm_ba', 'iof_icm_clam'}
                scribe_m = zeros(1,n_vals);
            otherwise
                scribe_m = read_scribes(param, gname);
        end
        n_scribes_m = sum(scribe_m(1:n_vals).*config.(gname));
        disp([' # of scribes (', gname,'): ', num2str(n_scribes_m)])
        n_scribes = n_scribes + n_scribes_m;
    end
end
disp([' total # of scribes: ', num2str(n_scribes)])

end

function scribe_flags = read_scribes(param, iof_group)
% Read the scribe flags from param.nml file

fid = fopen(param,'r');
if fid < 0; error('Cannot open file.'); end

scribe_flags = [];
while ~feof(fid)
    line = fgetl(fid);

    % skip empty lines
    if isempty(line); continue; end

    % look for group
    pattern = [iof_group '\((\d+)\)'];
    tok = regexp(line, pattern, 'tokens');
    if isempty(tok); continue; end

    idx = str2double(tok{1}{1});
    if contains(line, '3D vector')
        val = 2;
    elseif contains(line, '3D')
        val = 1;
    elseif contains(line, '2D')
        val = 0;
    else
        val = NaN;
    end
    scribe_flags(idx) = val; %#ok<AGROW>
end
fclose(fid);
end