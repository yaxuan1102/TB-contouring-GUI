function GUIforTB(action)
global handle
% Copyright, 2020, Ya-Xuan Yang, All rights reserved.


cd 'D:\2019 TVGH Chest\TB data preprocess\lesionGUI'; %%%%%%%% change
handle.savedir = '.\ManualROI'; % For TB lesion % handle.savedir = '.\LungMask'; % For lung seg.

if nargin<1
    close all
    handle.maininterface = figure('NumberTitle','off', 'Name','GUI for TB', 'Units','normalized', 'Position',[0.15 0.15 0.6 0.6], 'WindowState','maximized');
    action = 'start';
    handle.imfilename = [];
    
    % Create folder for mask
    folder = {'Pre'; 'Pos'}; %'PE'; 'PO'; 'AE'; 'AO'
    for f = 1:length(folder)
        chkpath = [handle.savedir '\' folder{f}];
        if ~isfolder(chkpath)
            mkdir(chkpath);
        end
    end
    
    % Create invisible.mat
    handle.xlsfile = [handle.savedir, '\invisible.xls'];  %'\NotSure.xls' (For lung segmentation)
    if isfile(handle.xlsfile)
        handle.invisible = readcell(handle.xlsfile);
    else
        handle.invisible = {'invisible'}; %'NotSure' (For lung segmentation)
        writecell(handle.invisible, handle.xlsfile);
    end
end


if strcmp(action,'start')
    handle.txtfolder = uicontrol('Parent',handle.maininterface, 'Style','text', 'Units','normalized', 'Position',[0.03 0.9 0.4 0.03],...
        'String','Folder : ', 'FontSize',13, 'HorizontalAlignment','left'); %'FontName','Yu Gothic UI'    
    handle.txtimg = uicontrol('Parent',handle.maininterface, 'Style','text', 'Units','normalized', 'Position',[0.03 0.85 0.4 0.03],...
        'String','Image : ', 'FontSize',13, 'HorizontalAlignment','left');
    handle.btnloadfile = uicontrol('Parent',handle.maininterface, 'Style','pushbutton', 'Units','normalized', 'Position',[0.1 0.75 0.1 0.05],...
        'String','Load File', 'FontSize',14, 'Callback','GUIforTB("loadfile")');
    handle.btnroi = uicontrol('Parent',handle.maininterface, 'Style','pushbutton', 'Units','normalized', 'Position',[0.1 0.65 0.1 0.05],...
        'String','Draw ROI', 'FontSize',14, 'Callback','GUIforTB("drawroi")', 'Enable','off');
    handle.btnshowroi = uicontrol('Parent',handle.maininterface, 'Style','pushbutton', 'Units','normalized', 'Position',[0.23 0.65 0.1 0.05],...
        'String','Show Previous ROI', 'FontSize',14, 'Callback','GUIforTB("showroi")', 'Enable','off');
    handle.btnsaveall = uicontrol('Parent',handle.maininterface, 'Style','pushbutton', 'Units','normalized', 'Position',[0.1 0.55 0.1 0.05],...
        'String','Save All', 'FontSize',14, 'Callback','GUIforTB("saveall")', 'Enable','off');
    handle.imgaxes = axes('Parent',handle.maininterface, 'Units','normalized', 'Position',[0.45 0.05 0.47 0.9]);

    handle.createmode.WindowStyle  = 'modal';
    handle.createmode.Interpreter = 'tex';
    
elseif strcmp(action, 'loadfile')
    srcdir = ['D:\2019 TVGH Chest\TB data preprocess\TVGH_mat_pre-post_20201105\', '*.mat']; %%%%%%%% change
    [handle.imfilename, filepath] = uigetfile(srcdir);
    handle.allinvisible = {handle.invisible{:,1}}; % All invisible
    if handle.imfilename
        handle.allfh = [];
        handle.btnroi.Enable = 'on';
        handle.btnshowroi.Enable = 'on';
        handle.btnsaveall.Enable = 'on';
        
        handle.imgname = strsplit(handle.imfilename, '.'); % Current name
        handle.imfolder = handle.imgname{1}([1 2 3]);
        handle.imfile = handle.imgname{1};
        handle.path = [handle.savedir '\' handle.imfolder '\' handle.imfile '_mask.mat'];
        
        handle.txtfolder.String = ['Folder : ', filepath];
        handle.txtimg.String = ['Image : ', handle.imfilename];
        
        handle.img = load([filepath, handle.imfilename]).DCMimg;
        imshow(handle.img);
    end
    
    
    
elseif strcmp(action, 'drawroi')
%     if handle.btnroi.BackgroundColor == [0.980.45 0.65];
%         handle.btnroi.BackgroundColor = [0.94 0.94 0.94];
%     else
    handle.btnshowroi.Enable = 'off';
    handle.btnroi.BackgroundColor = [0.98 0.45 0.65];
    drawfreehand('Color', [1 0.4 0.7], 'Multiclick', true);
    handle.btnroi.BackgroundColor = [0.94 0.94 0.94];
%     end


    
elseif strcmp(action, 'saveall')
    handle.btnshowroi.Enable = 'off';
    handle.allfh = findobj(handle.maininterface,'TYPE','images.roi.freehand'); %最早畫的在最後一個
    
    if handle.btnroi.BackgroundColor == [0.98 0.45 0.65];
        handle.istart = 2;
        handle.btnroi.BackgroundColor = [0.94 0.94 0.94];
    else
        handle.istart = 1;
    end    
    
    
    if isvalid(handle.allfh)
        handle.detvalid = 1;
    elseif (handle.istart == 2) && (length(handle.allfh)==1)
        handle.detvalid = 0;
    else
        handle.detvalid = 0;
    end
    
    
    if handle.detvalid == 1 % With fh       isvalid(handle.allfh) % 
        handle.cbmask = [];
        for i=handle.istart:length(handle.allfh)
            roi = handle.allfh(i).Position;
            imgsize = size(handle.img);
            handle.mask = poly2mask(roi(:,1), roi(:,2), imgsize(1), imgsize(2));
            handle.cbmask = cat(3, handle.cbmask, handle.mask);
        end
        finalmask = double(any(handle.cbmask, 3));

        if ~isfile(handle.path)
            if ~any(strcmp(handle.allinvisible, handle.imfile))
                save(handle.path, 'finalmask');
                msgbox('\fontsize{12}Save done!', handle.createmode);
            else
                btn1 = 'Remove from invisible list. Save ROI !';
                btn2 = 'Exit. Keep previous record.';
                opts = struct('Default',btn1, 'Interpreter','tex');
                ansRmInvisible = questdlg('\fontsize{12}Already been recorded in invisible list.', 'Saving Check', btn1, btn2, opts);
                switch ansRmInvisible
                    case btn1
                        handle.dupsbj = find(strcmp(handle.imfile, handle.allinvisible));
                        handle.invisible(handle.dupsbj) = [];
                        handle.xlsfile = [handle.savedir, '\invisible.xls'];
                        delete(handle.xlsfile);
                        writecell(handle.invisible, handle.xlsfile); % 'WriteMode','replacefile'
                        save(handle.path, 'finalmask');
                        msgbox({'\fontsize{12}Remove from invisible list.' ; 'ROI-saving was done !'}, handle.createmode);
                    case btn2
                        handle.btnroi.Enable = 'off';
                        handle.btnsaveall.Enable = 'off';
                        return
                end
            end
            
        else
            opts = struct('Default','Yes', 'Interpreter','tex');
            ansSaveROI = questdlg('\fontsize{12}Overwrite the previous record?', 'Saving Check', 'Yes', 'No', opts);
            switch ansSaveROI
                case 'Yes'
                    save(handle.path, 'finalmask');
                    msgbox('\fontsize{12}Overwrite done!', handle.createmode);
                case 'No'
                    return
            end
        end
        
    elseif handle.detvalid == 0 % Cannot see
        btn1 = 'Cannot, save it!';
        btn2 = 'Exit and draw ROI.';
        opts = struct('Default',btn1, 'Interpreter','tex');
        ansVisible = questdlg('\fontsize{12}Can not see TB lesions?', 'Visible Check', btn1, btn2, opts);
        switch ansVisible
            case btn1
                if ~isfile(handle.path)
                    SaveInvisible();
                else
                    btn1 = 'Remove ROI, save as invisible.';
                    btn2 = 'Exit and draw (or show previous) ROI.';
                    opts = struct('Default',btn2, 'Interpreter','tex');
                    ansRmROI = questdlg('\fontsize{12}Exist previously-saved ROI.', 'Saving Check', btn1, btn2, opts);                    
                    switch ansRmROI
                        case btn1
                            delete(handle.path);
                            handle.invisible{end+1, 1} = handle.imfile;
                            writecell(handle.invisible, handle.xlsfile);
                            msgbox({'\fontsize{12}Remove previously-saved ROI.' ; 'Save as invisible !'}, handle.createmode);
                        case btn2
                            handle.btnshowroi.Enable = 'on';
                            return
                    end
                end
            case btn2
                return
        end
    end
    
    
    
elseif strcmp(action, 'showroi')
    handle.showfile = [handle.savedir '\' handle.imfolder '\' handle.imfile '_mask.mat'];
    if isfile(handle.showfile)
        handle.loadmask = load(handle.showfile).finalmask;
        handle.bw = bwboundaries(handle.loadmask);
        for j = 1:length(handle.bw)
            drawfreehand(gca, 'Position', fliplr(handle.bw{j}));
        end
    else
        opts = struct('WindowStyle','model', 'Interpreter','tex');
        warndlg('\fontsize{12} No previous record!', 'Warning', opts);
    end
    
end
end


function SaveInvisible()
global handle
if ~any(strcmp(handle.allinvisible, handle.imfile))
    handle.invisible{end+1, 1} = handle.imfile;
    writecell(handle.invisible, handle.xlsfile);
    msgbox('\fontsize{12}Save as invisible!', handle.createmode);
else
    opts = struct('WindowStyle','model', 'Interpreter','tex');
    warndlg('\fontsize{12} Already been recorded in invisible list!', 'Warning', opts);
end
end