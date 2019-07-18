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
axexrange = 2;
axexrange_ch3 = 2;
fontsize = 12;

axes(handles.axes2);
axes2handle = plot(0 ,0, 'o');
axis([-axexrange axexrange -axexrange axexrange]);
set(gca,'FontSize', fontsize);

axes(handles.axes3);
axes3handle = plot(0 ,0, 'o');
axis([-axexrange axexrange -axexrange axexrange]);
set(gca,'FontSize', fontsize);

axes(handles.axes4);
axes4handle = plot(0 ,0, 'o');
axis([-axexrange axexrange -axexrange axexrange]);
set(gca,'FontSize', fontsize);

axes(handles.axes5);
axes5handle = plot(0 ,0, 'o');
axis([-axexrange_ch3  axexrange_ch3  -axexrange_ch3  axexrange_ch3 ]);
set(gca,'FontSize', fontsize);

handles.output = hObject;
guidata(hObject, handles);

if ispic == 1
    ImPeriod = 5000/ 1000.0;  % 5000ms
else
    ImPeriod = 600/ 1000.0;  % 600ms
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
     
    [channel0QPSK, channel1QPSK, channel2QPSK, channel3QPSK, ~] = ...
        WQLdemodulator(channel0Data, channel1Data, channel2Data, channel3Data, sampleRate);
    if channel0_en == 1
        if ispic == 1
            set(axes2handle, 'XData', constellation0, 'YData', constellation0);
        else
            set(axes2handle, 'XData', real(channel0QPSK), 'YData', imag(channel0QPSK));
        end       
    end
    
    if channel1_en == 1
        if ispic == 1
            set(axes3handle, 'XData', constellation0, 'YData', constellation0);
        else
            set(axes3handle, 'XData', real(channel1QPSK), 'YData',imag(channel1QPSK));
        end   
    end
    
    if channel2_en == 1
        if ispic == 1
            set(axes4handle, 'XData', constellation0, 'YData', constellation0);
        else
            set(axes4handle, 'XData', real(channel2QPSK), 'YData', imag(channel2QPSK));
        end   
    end
    
    if channel3_en == 1
        if ispic == 1
            set(axes5handle, 'XData', constellation0, 'YData', constellation0);
        else
            set(axes5handle, 'XData', real(channel3QPSK), 'YData', imag(channel3QPSK));
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
