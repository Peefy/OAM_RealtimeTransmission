function varargout = oam_realtime_demodulator_pic_gui(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @oam_realtime_demodulator_pic_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @oam_realtime_demodulator_pic_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

%% Gui Load
function oam_realtime_demodulator_pic_gui_OpeningFcn(hObject, eventdata, handles, varargin)

global axes2handle
global axes3handle
global axes4handle
global axes5handle
global pic_t
global ispic

pic_t = 0;
axexrange = 38;
axexrange_ch3 = 38;
fontsize = 12;

axes(handles.axes2);
axes2handle = scatter([-8, 8], [-8, 8], 20, 'filled');
axis([-axexrange axexrange -axexrange axexrange]);
set(gca,'FontSize', fontsize);

axes(handles.axes3);
axes3handle = scatter([-8, 8], [-8, 8], 20, 'filled');
axis([-axexrange axexrange -axexrange axexrange]);
set(gca,'FontSize', fontsize);

axes(handles.axes4);
axes4handle = scatter([-8, 8], [-8, 8], 20, 'filled');
axis([-axexrange axexrange -axexrange axexrange]);
set(gca,'FontSize', fontsize);

axes(handles.axes5);
axes5handle = scatter([-8, 8], [-8, 8], 20, 'filled');
axis([-axexrange_ch3  axexrange_ch3  -axexrange_ch3  axexrange_ch3 ]);
set(gca,'FontSize', fontsize);

handles.output = hObject;
guidata(hObject, handles);

if ispic == 1
    ImPeriod = 5000 / 1000.0;  % 5000ms
else
    ImPeriod = 600 / 1000.0;  % 600ms
end
timerPic = timer('TimerFcn', {@timerCallback, handles}, 'ExecutionMode', 'fixedDelay', 'Period', ImPeriod);
set(handles.figure1, 'DeleteFcn', {@DeleteFcn, timerPic, handles});
start(timerPic);


%% Gui output
function varargout = oam_realtime_demodulator_pic_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


%% timer func
function timerCallback(hObject, eventdata, handles)
global channel0Data
global channel1Data
global channel2Data
global channel3Data
global channel0QPSK
global channel1QPSK
global channel2QPSK
global channel3QPSK
global axes2handle
global axes3handle
global axes4handle
global axes5handle
global ispic

channel_pic_en = ispic;
channel0_en = 1;
channel1_en = 1;
channel2_en = 1;
channel3_en = 1;

datanum = length(channel0Data);
if datanum ~= 0
    [~, sampleRate] = getdatanum();
    % [QPSK0, QPSK1, QPSK2, QPSK3] = PolitDemodulator2(channel0Data, channel3Data, sampleRate);
    if channel_pic_en == 1
        axes(handles.axes6);
        DatCh_Pic = channel3Data;
        [~, Picture] = PicDemodulator(DatCh_Pic, sampleRate);
        Compress(Picture);
    end
    if channel0_en == 1
        if ispic == 1
            [constellation0, ~] = PicDemodulator(channel0Data, sampleRate);
            set(axes2handle, 'XData', constellation0, 'YData', constellation0);
        else
            [channel0QPSK, ~] = PolitDemodulatorch0(channel0Data, sampleRate);
            set(axes2handle, 'XData', channel0QPSK(1,:), 'YData', channel0QPSK(2,:));
        end       
    end
    
    if channel1_en == 1
        if ispic == 1
            [constellation0, ~] = PicDemodulator(channel1Data, sampleRate);
            set(axes3handle, 'XData', constellation0, 'YData', constellation0);
        else
            [channel1QPSK, ~] = PolitDemodulatorch1(channel1Data, sampleRate);
            set(axes3handle, 'XData', channel1QPSK(1,:), 'YData', channel1QPSK(2,:));
        end   
    end
    
    if channel2_en == 1
        if ispic == 1
            [constellation0, ~] = PicDemodulator(channel2Data, sampleRate);
            set(axes4handle, 'XData', constellation0, 'YData', constellation0);
        else
            [channel2QPSK, ~] = PolitDemodulatorch2(channel2Data, sampleRate);
            set(axes4handle, 'XData', channel2QPSK(1,:), 'YData', channel2QPSK(2,:));
        end   
    end
    
    if channel3_en == 1
        if ispic == 1
            [constellation0, ~] = PicDemodulator(channel3Data, sampleRate);
            % BPSK
            set(axes5handle, 'XData', constellation0, 'YData', constellation0);
        else
            [channel3QPSK, ~] = PolitDemodulatorch3(channel3Data, sampleRate);
            % QPSK
            set(axes5handle, 'XData', channel3QPSK(1,:), 'YData', channel3QPSK(2,:));
        end   
    end
end

%% Gui close func
function DeleteFcn(hObject, eventdata, timer, handles)
stop(timer);

function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global datashownum
global channel0Data
num = datashownum;
fprintf('%d %d', num, length(channel0Data));
axes(handles.axesPic) 
gca;
plot(rand(5));
set(handles.pushbutton1, 'String', num2str(length(channel0Data)));
