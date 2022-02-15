function cmp = getPyPlot_cMap(nam,n,keepAlpha,pyCmd)
% cmp = getPyPlot_cMap(nam [, n, keepAlpha, pyCmd])
%
%
% ::INPUT::
%
% nam:      Colormap name from matplotlib library (case sensitve!). See
%           below. Alternatively, '!GetNames' returns a cellstring of
%           available colormaps.
% n:        Number of Colors; defaults to 128
% keepAlpha: Switch to keep the alpha channel of the colormap (4th colum);
%           defaults to false. If true, a Nx4 matrix is returned in cmp
%           (instead of Nx3).
% pyCmd:    python command; defaults to 'python'
%
% 
% ::OUTPUT::
%
% cmp       A Nx3 (Nx4 if keepAlpha is true) double array of RGB(A) values.
%
%
% Colormap name can be one of the following:
%   ###  NOTE: the set of available colormaps  ###
%   ###  depends on your python installation!  ###
%
% Accent        	Accent_r      	afmhot        	afmhot_r      
% autumn        	autumn_r      	binary        	binary_r      
% Blues         	Blues_r       	bone          	bone_r        
% BrBG          	BrBG_r        	brg           	brg_r         
% BuGn          	BuGn_r        	BuPu          	BuPu_r        
% bwr           	bwr_r         	cividis       	cividis_r     
% CMRmap        	CMRmap_r      	cool          	cool_r        
% coolwarm      	coolwarm_r    	copper        	copper_r      
% cubehelix     	cubehelix_r   	Dark2         	Dark2_r       
% flag          	flag_r        	gist_earth    	gist_earth_r  
% gist_gray     	gist_gray_r   	gist_heat     	gist_heat_r   
% gist_ncar     	gist_ncar_r   	gist_rainbow  	gist_rainbow_r
% gist_stern    	gist_stern_r  	gist_yarg     	gist_yarg_r   
% GnBu          	GnBu_r        	gnuplot       	gnuplot2      
% gnuplot2_r    	gnuplot_r     	gray          	gray_r        
% Greens        	Greens_r      	Greys         	Greys_r       
% hot           	hot_r         	hsv           	hsv_r         
% inferno       	inferno_r     	jet           	jet_r         
% magma         	magma_r       	nipy_spectral 	nipy_spectral_r
% ocean         	ocean_r       	Oranges       	Oranges_r     
% OrRd          	OrRd_r        	Paired        	Paired_r      
% Pastel1       	Pastel1_r     	Pastel2       	Pastel2_r     
% pink          	pink_r        	PiYG          	PiYG_r        
% plasma        	plasma_r      	PRGn          	PRGn_r        
% prism         	prism_r       	PuBu          	PuBu_r        
% PuBuGn        	PuBuGn_r      	PuOr          	PuOr_r        
% PuRd          	PuRd_r        	Purples       	Purples_r     
% rainbow       	rainbow_r     	RdBu          	RdBu_r        
% RdGy          	RdGy_r        	RdPu          	RdPu_r        
% RdYlBu        	RdYlBu_r      	RdYlGn        	RdYlGn_r      
% Reds          	Reds_r        	seismic       	seismic_r     
% Set1          	Set1_r        	Set2          	Set2_r        
% Set3          	Set3_r        	Spectral      	Spectral_r    
% spring        	spring_r      	summer        	summer_r      
% tab10         	tab10_r       	tab20         	tab20_r       
% tab20b        	tab20b_r      	tab20c        	tab20c_r      
% terrain       	terrain_r     	viridis       	viridis_r     
% winter        	winter_r      	Wistia        	Wistia_r      
% YlGn          	YlGn_r        	YlGnBu        	YlGnBu_r      
% YlOrBr        	YlOrBr_r      	YlOrRd        	YlOrRd_r 
% 
% V 1.4; Konrad Schumacher, 02.2021

if strcmpi(nam,'!GetNames')
    % translate switch to retrieve colormap names into python-switch:
    nam = 'listCMapNames';
end


% defaults:
if ~exist('n','var') || isempty(n)
    n = 128;
end
if ~exist('keepAlpha','var') || isempty(keepAlpha)
    keepAlpha = 0;
end
if ~exist('pyCmd','var') || isempty(pyCmd)
    pyCmd = 'python';
end


% check if python script is present
pyScript = which('pyplotCMap2txt.py');
assert(~isempty(pyScript), 'getPyPlot_cMap:PyScriptNotFound', ...
    'Could not find python script (%s).','pyplotCMap2txt.py');

tmpf = tempname;

% call python script
comd = sprintf('%s "%s" %s -o "%s" -n %d', pyCmd, pyScript, nam, tmpf, n);
[s,m] = system(comd);

% check if system command ran w/o error
if s~=0
    baseME = MException('getPyPlot_cMap:SystemCMDFailed', ...
        'There was an error executing the command\n\t%s\nSystem returned:\n\t%s', ...
        comd, m);
    
    errPatterns = {'(?<=ModuleNotFoundError: ).*$' ...
                   'argument cmName: invalid choice: [''\d\w+]+'};
    mtch = regexp(m,errPatterns,'match','once');
    
    if ~isempty(mtch{1}) % ModuleNotFoundError
        ME = MException('getPyPlot_cMap:SystemCMDFailed:ModulNotFound', ...
            'Python is missing a required module: %s', mtch{1});
        
    elseif ~isempty(mtch{2}) % cmName: invalid choice
        ME = MException('getPyPlot_cMap:SystemCMDFailed:InvalidChoice', ...
            'The chosen colormap name was not found in the python installation: %s', ...
            mtch{2});
        
    else % UNHANDLED CASE
        ME = MException('getPyPlot_cMap:SystemCMDFailed:Unhandled', ...
            'There was an unexpected error while executing the python script. Sorry.');
    end
    
    throw(baseME.addCause(ME));
end


if strcmp(nam,'listCMapNames')
    % cMap names retrieved; read text file
    fid = fopen(tmpf,'r');
    cmp = textscan(fid,'%s');
    fclose(fid);
    cmp = cmp{1};
    
else
    % load cMap data from text file
    cmp = load(tmpf,'-ascii');

    if keepAlpha
    else % remove 4th column of alpha values
        cmp = cmp(:,1:3);
    end
end


% delete temp-file
delete(tmpf);

end

