function varargout = MPanTran(NAME, TSTOP, MEMVARS, varargin)
% MPanTran runs a PAN transient analysis. A netlist must be already loaded
% with MPanNetLoad.
%
% Usage: MPanTran(NAME, TSTOP)
%        MPanTran(NAME, TSTOP, [], varargin)
%        S = MPanTran(NAME, TSTOP, MEMVARS, varargin)
%
% MPanTran(NAME, TSTOP) runs a PAN transient analysis whose identifier is
% NAME. The simulation is perfomed up to TSTOP. The default options are
% used.
%
% MPanTran(NAME, TSTOP, [], varargin) runs a PAN transient analysis whose
% identifier is NAME. The varargin variables are used to specify proper
% OPTIONS to be used by the transient analysis.
% varargin must be a sequence of pairs as 'NAME1',VALUE1,'NAME2',VALUE2,...
% where the name of the options and the allowed values are specified by the
% PAN simulator documentation. The option "mem" cannot be used since it is
% emulated by the MEMVARS input detailed below.
%
% The simulation is perfomed from 0 (or tstart if
% specified in the options) to TSTOP.
%
% S = MPanTran(NAME, TSTOP, MEMVARS, varargin) works as the previous one
% but S is an output cell arrays and each cell contains
% a label and a waveform. The waveform are those specified with the MEMVARS
% input. If MEMVARS is empty S is empty. MEMVARS must be an array of
% strings or a cell array of chars or a cell array of strings.
%
% Angelo Brambilla - Federico Bizzarri - Daniele Linaro
% Copyright (c) 2015.
% Revision: 2.0 $Date: 2022/03/10$
%
global MPanSuite_NETLIST_INFO
if isempty(MPanSuite_NETLIST_INFO) || isempty(MPanSuite_NETLIST_INFO.MPanSuite_NETLIST_NAME)
    error('MPanSuiteError: a MPanSuiteNetlist is not loaded yet.')
end

if nargin < 2
    error('MPanSuiteError: at least 2 input arguments are required.')
end

if nargout > 1
    error('MPanSuiteError: no more than 1 output can be assigned')
end

if nargin > 3
    if ~isempty(MEMVARS) && nargout == 0
        warning('The MEMVARS input is not empty but no output has been required')
    end
    if rem(nargin,2)  == 0
        error('Beside NAME, TSTOP, and MEMVARS an even number of inputs is expected')
    end
end

str_command = [NAME ' tran tstop = ' num2str(TSTOP,'%23.16e')];


if nargout > 0 && ~isempty(MEMVARS)
    m = size(varargin,2);
    varargin{1,m+1} = 'mem';
    varargin{1,m+2} = MEMVARS;
    NAME_ = NAME;
elseif  nargout > 0 && isempty(MEMVARS)
    warning('The MEMVARS input is empty but an output has been required')
end

if nargin > 2
    [str_command, OPTIONS] = MPanStrCommandComplete(str_command,varargin{:});
end

clear NAME TSTOP MEMVARS varargin
pansimc(str_command);

MPanUpdateRawFilesList();

if nargout == 1
    S = [];
    if exist('OPTIONS','var') && isfield(OPTIONS,'mem')
        if ~isempty(OPTIONS.mem)
            nmem = numel(OPTIONS.mem);
            S = cell(nmem,1);
            tmp = struct('label',[],'signal',[]);
            for k = 1:nmem
                tmp.label = OPTIONS.mem{k};
                c_lab = [NAME_ '.' OPTIONS.mem{k}];
                tmp.signal = panget(c_lab);
                S{k} = tmp;
            end
            varargout{1} = S;
        end
    end
    if isempty(S)
        warning('MPAnSuiteWarning: an output is expected but it is empty since either the mem option was not given or its value is an empty list');
        varargout{1} = [];
    end
end
