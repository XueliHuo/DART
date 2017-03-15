function plot_ens_time_series(diagn_file, truth_file)

%% DART:plot_ens_time_series - time series of ensemble and truth (if available)
%
% plot_ens_time_series    interactively queries for the needed information.
%              Since different models potentially need different pieces of
%              information ... the model types are determined and additional
%              user input may be queried.
%              The first filename specifies the file with the ensemble mean.
%              If a second filename is supplied, it is used to plot the truth.
%              If no filenames are provided, you will be prompted for filenames.
%              Only the filename containing the ensemble mean is required.
%
% Example 1  (Prompt for filenames. Defaults are 'preassim.nc' and 'perfect_output.nc')
% plot_ens_mean_time_series
%
% Example 2
% diagn_file = 'preassim.nc';
% plot_ens_mean_time_series(diagn_file)
%
% Example 3 
% truth_file = 'perfect_output.nc';
% diagn_file = 'postassim.nc';
% plot_ens_time_series

%% DART software - Copyright UCAR. This open source software is provided
% by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% DART $Id$

if (nargin > 2)
   error('Must supply at most 2 filenames.')
elseif (nargin == 0)
   disp(' ')
   disp('Input name of ensemble trajectory file:')
   diagn_file = input('<cr> for preassim.nc\n','s');
   if isempty(diagn_file)
      diagn_file = 'preassim.nc';
   end

   disp(' ')
   disp('OPTIONAL: if you have the true state and want it superimposed, provide')
   disp('        : the name of the input file. If not, enter a dummy filename.')
   disp('        : Input name of true model trajectory file:')

   truth_file = input('<cr> for perfect_output.nc\n','s');
   if isempty(truth_file)
      truth_file = 'perfect_output.nc';
   end
elseif (nargin == 1)
   disp(' ')
   disp('OPTIONAL: if you have the true state and want it superimposed, provide')
   disp('        : the name of the input file. If not, enter a dummy filename.')
   disp('        : Input name of true model trajectory file:')

   truth_file = input('<cr> for perfect_output.nc\n','s');
   if isempty(truth_file)
      truth_file = 'perfect_output.nc';
   end
end

pinfo = CheckModel(diagn_file); % also gets default values for this model.

if (exist(truth_file,'file')==2)
   pinfo  = rmfield(pinfo,{'time','time_series_length'});
   MyInfo = CheckModelCompatibility(truth_file, diagn_file);
   pinfo  = CombineStructs(pinfo,MyInfo);
else
   truth_file = [];
end

pinfo.diagn_file = diagn_file;
pinfo.truth_file = truth_file;

clear MyInfo mynames myname ifield

%% For each model, do what needs to be done.

switch lower(pinfo.model)

   case {'9var','lorenz_63','lorenz_84','lorenz_96','lorenz_96_2scale', ...
	 'forced_lorenz_96','lorenz_04','ikeda','simple_advection'}

      varid = SetVariableID(pinfo);      % queries for variable IDs if needed.
      pinfo.var        = varid.var;
      pinfo.var_inds   = varid.var_inds;

      fprintf('Comparing %s and \n          %s\n', pinfo.truth_file, pinfo.diagn_file)
      disp(['Using State Variable IDs ', num2str(pinfo.var_inds)])
      clear varid

   case {'fms_bgrid'}

      pinfo = GetBgridInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   case {'cam'}

      pinfo.prior_file     = [];
      pinfo.posterior_file = [];
      pinfo                = GetCamInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   case {'wrf'}

      pinfo = GetWRFInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   case {'pe2lyr'}

      pinfo = GetPe2lyrInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   case {'mitgcm_ocean'}

      pinfo = GetMITgcm_oceanInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   case {'mpas_atm'}

      pinfo = GetMPAS_ATMInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   case {'sqg'}

      pinfo = GetSqgInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   case {'pop'}

      pinfo = GetPOPInfo(pinfo, diagn_file, 'PlotEnsTimeSeries');

   otherwise

      error('model %s not implemented yet', pinfo.model)

end

pinfo

PlotEnsTimeSeries( pinfo )


% <next few lines under version control, do not edit>
% $URL$
% $Revision$
% $Date$