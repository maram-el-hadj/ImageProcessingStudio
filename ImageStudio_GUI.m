function ImageStudio_GUI

clc; close all;

%% ====== FIGURE ======
fig = uifigure('Name','IMAGE PROCESSING STUDIO',...
    'Position',[100 100 1200 700],...
    'Color',[0.94 0.96 1]);

%% ====== AXES ======
ax1 = uiaxes(fig,'Position',[350 370 350 250]);
title(ax1,'Original');

ax2 = uiaxes(fig,'Position',[750 370 350 250]);
title(ax2,'Result');

axHist = uiaxes(fig,'Position',[350 50 350 250]);
title(axHist,'Histogram');

%% ====== LOAD IMAGE ======
try
    G = imread('BIRD.BMP');
catch
    G = imread('cameraman.tif');
end

if size(G,3)==3
    G = rgb2gray(G);
end

imshow(G,'Parent',ax1)
currentImg = G; % keep track of the current image

%% ====== CONTROLS PANEL ======
panel = uipanel(fig,...
    'Title','Controls',...
    'Position',[20 50 300 600],...
    'BackgroundColor',[0.85 0.90 1]);

%% Rotation
uilabel(panel,'Text','Rotation Angle:',...
    'Position',[20 540 120 22],'FontWeight','bold');
angleField = uieditfield(panel,'numeric',...
    'Position',[160 540 100 22],'Value',0);

btnRotate = uibutton(panel,'push',...
    'Text','Rotate',...
    'Position',[80 500 120 30],...
    'BackgroundColor',[0.4 0.6 1],...
    'ButtonPushedFcn',@(btn,event) rotateImage);

%% Noise
uilabel(panel,'Text','Noise Density:',...
    'Position',[20 460 120 22],'FontWeight','bold');
noiseField = uieditfield(panel,'numeric',...
    'Position',[160 460 100 22],'Value',0.02);

btnNoise = uibutton(panel,'push',...
    'Text','Add Noise',...
    'Position',[80 420 120 30],...
    'BackgroundColor',[1 0.6 0.4],...
    'ButtonPushedFcn',@(btn,event) addNoise);

%% Filters
uilabel(panel,'Text','Filter Type:',...
    'Position',[20 380 120 22],'FontWeight','bold');
filterDrop = uidropdown(panel,...
    'Items',{'Sobel','Roberts','Laplacian','Median'},...
    'Position',[80 350 140 25]);

btnFilter = uibutton(panel,'push',...
    'Text','Apply Filter',...
    'Position',[80 310 120 30],...
    'BackgroundColor',[0.8 0.5 1],...
    'ButtonPushedFcn',@(btn,event) applyFilter);

%% Invert
btnInvert = uibutton(panel,'push',...
    'Text','Invert Image',...
    'Position',[80 270 120 30],...
    'BackgroundColor',[1 0.4 0.4],...
    'ButtonPushedFcn',@(btn,event) invertImage);

%% Reset
btnReset = uibutton(panel,'push',...
    'Text','Reset',...
    'Position',[80 230 120 30],...
    'BackgroundColor',[0.7 0.7 0.7],...
    'ButtonPushedFcn',@(btn,event) resetImage);

%% Histogram Controls
uilabel(panel,'Text','Histogram Min:',...
    'Position',[20 190 100 22],'FontWeight','bold');
histMinField = uieditfield(panel,'numeric','Position',[130 190 60 22],'Value',0);

uilabel(panel,'Text','Histogram Max:',...
    'Position',[20 160 100 22],'FontWeight','bold');
histMaxField = uieditfield(panel,'numeric','Position',[130 160 60 22],'Value',255);

uilabel(panel,'Text','Bins:',...
    'Position',[20 130 100 22],'FontWeight','bold');
histBinsField = uieditfield(panel,'numeric','Position',[130 130 60 22],'Value',256);

btnHist = uibutton(panel,'push',...
    'Text','Show Histogram',...
    'Position',[80 90 120 30],...
    'BackgroundColor',[0.3 0.8 0.5],...
    'ButtonPushedFcn',@(btn,event) showHistogram);

%% Dark/Light Mode Button (en bas à droite)
btnMode = uibutton(fig,'push',...
    'Text','Dark Mode',...
    'Position',[1100 20 80 30],...
    'BackgroundColor',[0.5 0.5 0.5],...
    'ButtonPushedFcn',@(btn,event) toggleMode);

isDarkMode = false;

%% ====== FUNCTIONS ======
    function rotateImage
        angle = angleField.Value;
        currentImg = imrotate(currentImg,angle,'crop');
        imshow(currentImg,'Parent',ax2)
        title(ax2,['Rotation ',num2str(angle),'°'])
    end

    function addNoise
        d = noiseField.Value;
        currentImg = imnoise(currentImg,'salt & pepper',d);
        imshow(currentImg,'Parent',ax2)
        title(ax2,'Noisy Image')
    end

    function applyFilter
        choice = filterDrop.Value;
        switch choice
            case 'Sobel'
                currentImg = edge(currentImg,'sobel');
            case 'Roberts'
                currentImg = edge(currentImg,'roberts');
            case 'Laplacian'
                h = fspecial('laplacian',0.2);
                currentImg = imfilter(currentImg,h,'replicate');
            case 'Median'
                currentImg = medfilt2(currentImg,[3 3]);
        end
        imshow(currentImg,'Parent',ax2)
        title(ax2,['Filter: ',choice])
    end

    function invertImage
        currentImg = 255 - currentImg;
        imshow(currentImg,'Parent',ax2)
        title(ax2,'Inverted')
    end

    function resetImage
        currentImg = G;
        imshow(G,'Parent',ax1)
        cla(ax2)
        cla(axHist)
    end

    function showHistogram
        cla(axHist)
        hMin = histMinField.Value;
        hMax = histMaxField.Value;
        bins = histBinsField.Value;
        edges = linspace(hMin,hMax,bins+1);
        histogram(axHist,double(currentImg(:)),edges)
        title(axHist,'Histogram')
    end

    function toggleMode
        if ~isDarkMode
            fig.Color = [0.1 0.1 0.1];
            panel.BackgroundColor = [0.2 0.2 0.2];
            ax1.Color = [0.1 0.1 0.1];
            ax2.Color = [0.1 0.1 0.1];
            axHist.Color = [0.1 0.1 0.1];
            btnMode.Text = 'Light Mode';
            isDarkMode = true;
        else
            fig.Color = [0.94 0.96 1];
            panel.BackgroundColor = [0.85 0.90 1];
            ax1.Color = [1 1 1];
            ax2.Color = [1 1 1];
            axHist.Color = [1 1 1];
            btnMode.Text = 'Dark Mode';
            isDarkMode = false;
        end
    end

end