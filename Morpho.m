%% Load sample
clear all;
close all;
loop = 0;
while loop == 0;
    load('C:\MATLAB\LUP.mat');
    if LUP == 0;
        LUP = 'C:\';
    end
    ftypes = {'*.jpg','JPEG';'*.bmp','Bitmap';'*.tif','TIF'};
    [Filename, PATH] = uigetfile(ftypes,'Select image:',LUP);
    RPF = [PATH,Filename];
    cd 'C:\MATLAB';
    LUP = PATH;
    save LUP.mat LUP;
    I = imread(RPF);
    %%
    [D1, FileNm, D2] = fileparts(RPF);
    IC = size(I);
    ICb = size(IC);
    if ICb(1,2) == 3
        L = rgb2gray(I);
    else L = I;
    end
    %% Threshold/binarize
    K = medfilt2(L,[3 3]);
    imshow(I);
    % Select method of thresholding
    button = questdlg('Select thresholding method:',...
        'Select thresholding method:','Manual','Low Contrast(Auto)','Manual');
    switch button
        case 'Manual'
            MethT = 1;
        case 'Low Contrast(Auto)'
            MethT = 2;
    end
    close all;
    repro = 0;
    rep_adj = 0;
    try1 = 20;
    try2 = 40;
    while repro == 0;
        J = rangefilt(K);
        if MethT == 1;
            try1 = try1;
            J(J < try1) = 0;                     % Threshhold binary calculation
            J(J > try2) = 0;
            J(J >= try1) = 1;
            J = logical(J);
            M = J;
        else
            lvlM = graythresh(K);
            M = im2bw(K,lvlM);                   % Threshold autocalculation
            J = rangefilt(M);
        end

        imshow(J)
        s = size(J);
        X = [];
        button_repro = questdlg('Reprocessing required?','Reprocessing required?','Yes','Reset','No','No');
        switch button_repro
            case 'Yes'
                repro = 0;
                MethT = 1;
                try1_str = num2str(try1);
                try2_str = num2str(try2);
                rep_adj = inputdlg([{'Low'}, {'High'}],'Range:',1,[{try1_str}, {try2_str}]);
                try1 = str2double(rep_adj{1,1});
                try2 = str2double(rep_adj{2,1});
            case 'Reset'
                repro = 0;
                try1 = 20;
                try2 = 40;
            case 'No'
                repro = 1;
        end
    end


    %% Calculate parameters

    for row = 1:25:s(1)                 % Identification of objects (rowscan)
       for col=1:s(2)
          if J(row,col),
             break;
          end
       end
       contour = bwtraceboundary(J, [row, col], 'SW', 8, Inf, 'counterclockwise');  
       if(~isempty(contour))
          X = [X; {contour}];
       else
          hold on; plot(col, row,'rx','LineWidth',2);
       end
    end
    
    for row = s(1):-25:1                 % Identification of objects (descending rowscan)
       for col=s(2):-1:1
          if J(row,col),
             break;
          end
       end
       contour = bwtraceboundary(J, [row, col], 'NE', 8, Inf, 'clockwise');  
       if(~isempty(contour))
          X = [X; {contour}];
       else
          hold on; plot(col, row,'rx','LineWidth',2);
       end
    end

    for col = 1:25:s(2)                 % Identification of objects (columnscan)
       for row=1:s(1)
          if J(row,col),
             break;
          end
       end

       contour = bwtraceboundary(J, [row, col], 'NE', 8, Inf, 'counterclockwise');  
       if(~isempty(contour))
          X = [X; {contour}];
       else
          hold on; plot(col, row,'rx','LineWidth',2);
       end
    end
    
    
    for col = s(2):-25:1                 % Identification of objects (descending columnscan)
       for row=s(1):-1:1
          if J(row,col),
             break;
          end
       end

       contour = bwtraceboundary(J, [row, col], 'SW', 8, Inf, 'clockwise');  
       if(~isempty(contour))
          X = [X; {contour}];
       else
          hold on; plot(col, row,'rx','LineWidth',2);
       end
    end



    z1 = size(X);
    md = [];
    c = 0;
    for row = 1:z1(1,1);              % Deleting multiple object hits.
        md = [md; size(X{row,1})];
    end
    [junk, idx] = unique(md,'rows');
    Xa = X(sort(idx,1));

    z2 = size(Xa);                    % Delete erroneous object hits.
    md2 = [];
    for row = 1:z2(1,1);
        md2 = [md2; size(Xa{row,1})];
    end
    md2 = md2(:,1);
    fa = find(md2>100);
    Xb = Xa(fa,:);                    % Resultant x-y pair traces.

    z3 = size(Xb);
    hold on
    for obj1 = 1:z3(1,1);
        Pl = Xb{obj1,1};                % Plot reduced set
        plot(Pl(:,2),Pl(:,1),'g','LineWidth',2);
        CntCoord_lb = mean(Pl);
        lblObj = num2str(obj1);
        text(CntCoord_lb(2),CntCoord_lb(1),lblObj,'HorizontalAlignment',...
            'center','Color',[0 1 0],'BackgroundColor',[0 0 0],...
            'FontSize',24);
    end

    button2 = questdlg('Erroneous extra volume data?');  % Remove error volumes
    switch button2
        case 'Yes'
            b2 = 1;
        case 'No'
            b2 = 0;
        case 'Cancel'
            b2 = 2;
    end
    redc = [];
    redr = [];
    if b2 == 1;
        erd = impoly;
        pos = getPosition(erd);
        c = pos(:,1);
        r = pos(:,2);
        BWi = (roipoly(M,c,r));
        [redc, redr] = find(BWi==1);
    end


    BW = [];
    for item = 1:z3(1,1);
        c = [];
        r = [];
        A = Xb{item,1};                      % Define ROIs.
        c = A(:,2);
        r = A(:,1);
        BW = [BW; {roipoly(M,c,r)}];
    end


    %% Appropriately label individual objects
    prompt_obj = [];
    def_answ = [];
    for item = 1:z3(1,1);
        int_obj = [];
        int_obj = 'Object ';
        itm_x = num2str(item);
        int_obj = [int_obj, itm_x];
        prompt_obj = [prompt_obj; {int_obj}];
        def_answ = [def_answ; {FileNm}];
    end

    options.Resize='on';
    options.WindowStyle='normal';
    obj_label = inputdlg(prompt_obj,Filename,1,def_answ,options);




    %%
    zs = size(M);
    sr = size(redr);
    Mask1 = zeros(zs(1),zs(2));
    STATS = [];                % Calculate all properties using regionprops
    for obj = 1:z3(1,1);
        CObj = BW{obj,1};
        for erdc = 1:sr(1);
            CObj(redc(erdc), redr(erdc)) = 0;  % Subtract exclusion area
        end
        STATS = [STATS; regionprops(CObj, 'all')];
        Mask1 = Mask1 + CObj;  % Mask generation
    end


    OUT = {'Obj #' 'Area' 'Perimeter' 'Major Axis' 'Minor Axis'};
    countr_lbl = 0;
    for obj = 1:size(STATS,1);
        if STATS(obj).Area>1000;
            countr_lbl = countr_lbl + 1;
            Ar = STATS(obj).Area;
            Peri = STATS(obj).Perimeter;
            MajAL = STATS(obj).MajorAxisLength;
            MinAL = STATS(obj).MinorAxisLength;
            ObjL = obj_label(countr_lbl);
            ObjC = [ObjL, Ar, Peri, MajAL, MinAL];
            OUT = [OUT; ObjC];
        end
    end
    if b2 == 1;
        figure, imshow(Mask1);
    end

    button = questdlg('Save data?','Save?');
    switch button
        case 'Yes'
            b = 1;
        case 'No'
            b = 0;
        case 'Cancel'
            b = 2;
    end
    %%
    if b == 1;
        FileOut = [PATH FileNm '.xls'];
        xlswrite(FileOut, OUT);
    end
    %%
    cd(PATH);
    mkdir('Processed');
    movefile(Filename(),'Processed');
    
    %%
    loopq = questdlg('Process another sample?','Process another sample?','Yes','No','Cancel','Yes');
    switch loopq
        case 'Yes'
            loop = 0;
        case 'No'
            loop = 1;
        case 'Cancel'
            loop = 2;
    end
end
