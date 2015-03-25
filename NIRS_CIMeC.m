function NIRS_CIMeC

%
% Graphical User Interface to display NIRS data for CIMeC experiments 
%
% Usage - call NIRS_CIMeC from Matlab console
%
% Written by Matteo Caffini, PhD
% CIMeC - Universita' dgli Studi di Trento
% on March, 5th 2015 in Rovereto (TN)
%
% Copyright (C) 2015 Matteo Caffini <matteo.caffini@unitn.it>
%

Hmain = []; % handles to uicontrols and graphics
allData = load('subj(nSubj).mat'); % load data from ultragigamegamatrix
allData = allData.subj;
sampling_frequency = 15.625;
checkmark = char(hex2dec('2713')); % must be green, RGB [0 153/256 0]
cross = char(hex2dec('2718')); % must be red, RGB [204/256 0 0]
color_checkmark = [0 153/256 0];
color_cross = [204/256 0 0];
default_blocks_string = '[1:10]';

screenSize=get(0,'ScreenSize');
feature('DefaultCharacterSet', 'UTF8');

% Objects Dimensions
plotW = 100;
plotH = 100;
checkboxW = 70;
checkboxH = 14;
buttonW = 100;
buttonH = 30;
PopUpW = 120;
PopUpH = 16;
editBlocksW = 80;
editBlocksH = 14;
editBlocksCheckW = 20;
editBlocksCheckH = 14;
spaceW = 50;
spaceH = 50;
nplotW = 6;
nplotH = 4;
nplots = 20;
figureW = nplotW*plotW + (nplotW+1)*spaceW;   % Screen width in pixels
figureH = nplotH*plotH + (nplotH+1)*spaceH;   % Screen height in pixels

% Set color background
defaultColor = get(0,'DefaultUicontrolBackgroundcolor');

% Set font
if ismac
    defaultFontName = 'Lucida Grande';
    if sum(strcmp(listfonts,defaultFontName))<1
        defaultFontName = 'Helvetica';
    end 
elseif ispc
    defaultFontName = 'Lucida Sans Unicode';
    if sum(strcmp(listfonts,defaultFontName))<1
        defaultFontName = 'Helvetica';
    end
else
    defaultFontName = 'Helvetica';
end

% Set figure position
figurePosition = [screenSize(3)/2-figureW/2 screenSize(4)/2-figureH/2-20 figureW figureH];

% Draw main figure
Hmain.mainFigure = figure('Position',figurePosition, ...
    'Visible','off',...
    'Units','pixel', ...
    'Resize','off',...
    'Name','NIRS_CIMeC', ...
    'Numbertitle','off', ...
    'Tag','main_figure', ...
    'Color',defaultColor, ...
    'Toolbar','none', ...
    'Menubar','none', ...
    'DoubleBuffer','on', ...
    'DockControls','off',...
    'Renderer','OpenGL');

% TEST to be deleted
%time = 1:1:300;
%curves = [time;time.*time];

% Draw plots and reject checkboxes
%to_skip = [8,11,14,17];
counter_nans = 0;
for ww = 1:1:nplotW
    for hh = 1:1:nplotH
        channels = [8 9 10 18 19 20;6 nan 7 16 nan 17;4 nan 5 14 nan 15;1 2 3 11 12 13];
        %channels = channels';
        ii = channels(hh,ww);
        if isnan(ii)
            counter_nans = counter_nans + 1;
            switch counter_nans
                case 1
                    % Draw show/hide average and blocks checkboxes
                    Hmain.checkboxAverage = uicontrol('parent',Hmain.mainFigure,...
                        'Units','pixel',...
                        'Position',[ww*spaceW+(ww-.9)*plotW hh*spaceH+(hh-.4)*plotH checkboxW checkboxH],...
                        'Style','checkbox',...
                        'HorizontalAlignment','center',...
                        'FontWeight','bold',...
                        'FontSize',8,...
                        'FontName',defaultFontName,...
                        'BackgroundColor',defaultColor,...
                        'String','Average',...
                        'Callback',@refresh_plots,...
                        'Enable','on');
                    Hmain.checkboxBlocks = uicontrol('parent',Hmain.mainFigure,...
                        'Units','pixel',...
                        'Position',[ww*spaceW+(ww-.9)*plotW hh*spaceH+(hh-.7)*plotH checkboxW checkboxH],...
                        'Style','checkbox',...
                        'HorizontalAlignment','center',...
                        'FontWeight','bold',...
                        'FontSize',8,...
                        'FontName',defaultFontName,...
                        'BackgroundColor',defaultColor,...
                        'String','Blocks',...
                        'Callback',@refresh_plots,...
                        'Enable','on');
                case 2
                    % Draw choose subject and choose condition
                    subjectList{length(allData)} = 'spam';
                    for ii=1:1:length(allData)
                        subjectList{ii} = allData(ii).subjID; % fill with subj(nSubj) first column
                    end
                    Hmain.popUpSubject = uicontrol('parent',Hmain.mainFigure,...
                        'Style','popupmenu',...
                        'String',subjectList,...
                        'FontSize',8,...
                        'FontWeight','bold',...
                        'Value',1,...
                        'Position',[ww*spaceW+(ww-1.15)*plotW hh*spaceH+(hh-.4)*plotH PopUpW PopUpH],...
                        'Enable','on',...
                        'Callback',@refresh_plots);
                    conditionsList = {'Biomotion','Scramble','Rotation'};
                    Hmain.popUpCondition = uicontrol('parent',Hmain.mainFigure,...
                        'Style','popupmenu',...
                        'String',conditionsList,...
                        'FontSize',8,...
                        'FontWeight','bold',...
                        'Value',1,...
                        'Position',[ww*spaceW+(ww-1.15)*plotW hh*spaceH+(hh-.7)*plotH PopUpW PopUpH],...
                        'Enable','on',...
                        'Callback',@refresh_plots);
                case 3
                    % Do nothing
                    continue;
                case 4
                    % Draw Export jpg button
                    Hmain.exportJPG = uicontrol('parent',Hmain.mainFigure,...
                        'Units','pixel',...
                        'Position',[ww*spaceW+(ww-1)*plotW hh*spaceH+(hh-.65)*plotH buttonW buttonH],...
                        'Style','pushbutton',...
                        'FontWeight','bold',...
                        'FontSize',10,...
                        'FontName',defaultFontName,...
                        'String','Export jpg',...
                        'Value',0,...
                        'Callback',@export_jpg,...
                        'Enable','on');
                    % Draw global info 
                    
            end
            continue;
        else
            plot_Position = [ww*spaceW+(ww-1)*plotW hh*spaceH+(hh-1)*plotH plotW plotH];
            checkboxReject_Position = [plot_Position(1)+(plotW-checkboxW)/2 plot_Position(2)+1.05*plotH checkboxW checkboxH];
            editBlocks_Position = [plot_Position(1)+.2*(plotW-editBlocksW)/2 plot_Position(2)-0.2*plotH editBlocksW editBlocksH];
            editBlocksCheck_Position = [plot_Position(1)+1.05*editBlocksW plot_Position(2)-0.2*plotH editBlocksCheckW editBlocksCheckH];
            Hmain.Axes(ii) = axes('parent',Hmain.mainFigure,...
                'Units','Pixel',...
                'Position', plot_Position,...
                'Xlim',[0 1],'Ylim',[0 1], ...
                'XDir','normal','YDir','normal',...
                'Box','off', ...
                'XGrid','off','YGrid','off',...
                'XTickLabel',[],'YTickLabel',[],...
                'Fontsize',6,...
                'FontName',defaultFontName,...
                'Visible','on');
            Hmain.checkboxReject(ii) = uicontrol('parent',Hmain.mainFigure,...
                'Units','pixel',...
                'Position',checkboxReject_Position,...
                'Style','checkbox',...
                'HorizontalAlignment','center',...
                'FontWeight','normal',...
                'FontSize',8,...
                'FontName',defaultFontName,...
                'BackgroundColor',defaultColor,...
                'String',['Reject ' num2str(ii)],...
                'Callback',@refresh_plots,...
                'Enable','on');
            Hmain.editBlocks(ii) = uicontrol('parent',Hmain.mainFigure,...
                'Style','edit',...
                'String',default_blocks_string,...
                'HorizontalAlignment','center',...
                'FontSize',8,...
                'Value',1,...
                'Enable','on',...
                'Callback',@refresh_plots,...
                'Position',editBlocks_Position);
            Hmain.editBlocksCheck(ii) = uicontrol('parent',Hmain.mainFigure,...
                'Style','text',...
                'String',checkmark,...
                'HorizontalAlignment','center',...
                'FontSize',8,...
                'ForeGroundColor',color_checkmark,...
                'Value',1,...
                'Enable','on',...
                'Position',editBlocksCheck_Position);
        end
    end
end

    function refresh_plots(h,evt)
        
        % get current subject
        current_subject = get(Hmain.popUpSubject,'Value');
        % get current condition
        current_condition_val = get(Hmain.popUpCondition,'Value');
        condition_list = get(Hmain.popUpCondition,'String');
        current_condition = condition_list{current_condition_val};
        % get current checkboxes values
        blocks = get(Hmain.checkboxBlocks,'Value');
        average = get(Hmain.checkboxAverage,'Value');
        % get current curves in the form current_curves(samples,block,channel)
        if isempty(allData(current_subject).chan_raw)
            current_curves_hbo = nan;
            current_curves_hbd = nan;
        else
            n_current_channels = length(allData(current_subject).chan_raw);
            switch current_condition
                case 'Biomotion'
                    current_condition_hbo = 'hbo_biomotion';
                    current_condition_hbd = 'hbd_biomotion';
                case 'Scramble'
                    current_condition_hbo = 'hbo_scramble';
                    current_condition_hbd = 'hbd_scramble';
                case 'Rotation'
                    current_condition_hbo = 'hbo_rotation';
                    current_condition_hbd = 'hbd_rotation';
            end
            for channel=1:1:n_current_channels
                current_curves_hbo(:,:,channel) = allData(current_subject).chan_raw(channel).(current_condition_hbo);
                current_curves_hbd(:,:,channel) = allData(current_subject).chan_raw(channel).(current_condition_hbd);
            end
            %current_average_hbo(:,1,:) = mean(current_curves_hbo,2);
            %current_average_hbd(:,1,:) = mean(current_curves_hbd,2);
        end
        n_samples = length(current_curves_hbo);
        time_in_samples = 1:1:n_samples;
        time_in_seconds = time_in_samples /sampling_frequency;
        for aa = 1:1:nplots
            cla(Hmain.Axes(aa));
            axes(Hmain.Axes(aa));
            
            % get current blocks
            block_range_string = get(Hmain.editBlocks(aa),'String');
            expr = '\[[1234567890,:]+\]';
            i_start = regexp(block_range_string,expr);
            if isempty(i_start)
                set(Hmain.editBlocksCheck(aa),'String',cross,'ForeGroundColor',color_cross)
                % something has to be done here in the future
            else
                set(Hmain.editBlocksCheck(aa),'String',checkmark,'ForeGroundColor',color_checkmark)
                default_blocks = eval(default_blocks_string);
                block_range = eval(block_range_string);
                mask_blocks = not(ismember(default_blocks,block_range));
                for kk = default_blocks(mask_blocks)
                    current_curves_hbo(:,kk,aa) = nan(n_samples,1);
                    current_curves_hbd(:,kk,aa) = nan(n_samples,1);
                end
                if isnan(current_curves_hbo)
                    current_average_hbo = nan;
                    current_average_hbd = nan;
                else
                    current_average_hbo(:,1,aa) = nanmean(current_curves_hbo(:,:,aa),2);
                    current_average_hbd(:,1,aa) = nanmean(current_curves_hbd(:,:,aa),2);
                end
            end
            if isnan(current_curves_hbo)
                if exist('graph2d.constantline','class') == 8
                    hx = graph2d.constantline(0,'LineStyle',':','Color',[.7 .7 .7]);
                    changedependvar(hx,'x');
                    hy = graph2d.constantline(0,'LineStyle',':','Color',[.7 .7 .7]);
                    changedependvar(hy,'y');
                end
            else
                if exist('graph2d.constantline','class') == 8
                    hx = graph2d.constantline(0,'LineStyle',':','Color',[.7 .7 .7]);
                    changedependvar(hx,'x');
                    hy = graph2d.constantline(0,'LineStyle',':','Color',[.7 .7 .7]);
                    changedependvar(hy,'y');
                end
                if blocks
                    plot(time_in_seconds,current_curves_hbo(:,:,aa),'-r','Linewidth',1);
                    hold on
                    plot(time_in_seconds,current_curves_hbd(:,:,aa),'-b','Linewidth',1);
                    xmin_blocks = 0;
                    xmax_blocks = max(time_in_seconds);
                    ymin_blocks = min(min(current_curves_hbo(:)),min(current_curves_hbd(:)));
                    ymax_blocks = max(max(current_curves_hbo(:)),max(current_curves_hbd(:)));
                else
                    xmin_blocks = 0;
                    xmax_blocks = 0;
                    ymin_blocks = 0;
                    ymax_blocks = 0;
                end
                hold on
                if average
                    plot(time_in_seconds,current_average_hbo(:,:,aa),'-r','Linewidth',2);
                    hold on
                    plot(time_in_seconds,current_average_hbd(:,:,aa),'-b','Linewidth',2);
                    xmin_average = 0;
                    xmax_average = max(time_in_seconds);
                    ymin_average = min(min(current_average_hbo(:)),min(current_average_hbd(:)));
                    ymax_average = max(max(current_average_hbo(:)),max(current_average_hbd(:)));
                else
                    xmin_average = 0;
                    xmax_average = 0;
                    ymin_average = 0;
                    ymax_average = 0;
                end
                % set range here
                xmin(aa) = min(xmin_blocks,xmin_average);
                xmax(aa) = max(xmax_blocks,xmax_average);
                ymin(aa) = min(ymin_blocks,ymin_average);
                ymax(aa) = max(ymax_blocks,ymax_average);
                %set(Hmain.Axes(aa),'XTickLabel',[],'YTickLabel',[]);
                % eventually reject channel
                reject = get(Hmain.checkboxReject(aa),'Value');
                if reject
                    cla(Hmain.Axes(aa)); % to be changed in the future
                end
            end
        end
        % global plots range must be set here
        if not(exist('xmin'))
            xmin = -1;
        end
        if not(exist('xmax'))
            xmax = 1;
        end
        if not(exist('ymin'))
            ymin = -1;
        end
        if not(exist('ymax'))
            ymax = 1;
        end
        xminmin = min(xmin);
        xmaxmax = max(xmax);
        xrange = abs(xmaxmax-xminmin);
        if xrange == 0
            xrange = 1;
        end
        yminmin = min(ymin);
        ymaxmax = max(ymax);
        yrange = abs(ymaxmax-yminmin);
        if yrange == 0
            yrange = 1;
        end
        range_factor = 15;
        for aa = 1:1:nplots
            axes(Hmain.Axes(aa))
            axis([xminmin-xrange/range_factor xmaxmax+xrange/range_factor yminmin-yrange/range_factor ymaxmax+yrange/range_factor]);
        end
    end

    function reset_plots(h,evt)
        %current_subject = get(Hmain.popUpSubject,'Value');
        for bb=1:1:nplots
            % set objects visibility to on
            set(Hmain.checkboxReject(bb),'Enable','on');
            set(Hmain.Axes(bb),'Visible','on');
            % set objects values to whatever the f@#k you like
            set(Hmain.popUpSubject,'Value',3);
            set(Hmain.checkboxReject(bb),'Value',0);
            % set block of interest from BOI_table            
%             boi_table = allData(current_subject).BOI_table;
%             boi_blocks = find(boi_table(1:2:end)>0);
%            set(Hmain.editBlocks(bb),'String',boi_string);
        end
        refresh_plots;
    end

    function export_jpg(h,evt)
        % get current subject
        current_subject = get(Hmain.popUpSubject,'Value');
        current_subject_name = allData(current_subject).subjID;
        % get current condition
        current_condition_val = get(Hmain.popUpCondition,'Value');
        condition_list = get(Hmain.popUpCondition,'String');
        current_condition = condition_list{current_condition_val};
        figureName = [current_subject_name '_' current_condition '.jpg'];
        set(Hmain.mainFigure,'PaperPositionMode','auto')
        set(Hmain.mainFigure,'InvertHardcopy','off')
        print(Hmain.mainFigure, '-djpeg','-r150','-loose',figureName)
    end

set(Hmain.mainFigure,'Visible','on');
set(Hmain.checkboxBlocks,'Value',0);
set(Hmain.checkboxAverage,'Value',1);
reset_plots;
%refresh_plots;
end
