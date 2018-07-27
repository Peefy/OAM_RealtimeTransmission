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

global axes1handle
global axes2handle
global axes3handle
global axes4handle
global axes5handle
global t

t = 0;
axes(handles.axesPic);
x = -100 : 0.5: 100;
axes1handle = imshow(sin(x' * x));

axes(handles.axes2);
axes2handle = scatter([-8, 8], [-8, 8]);

axes(handles.axes3);
axes3handle = scatter([-8, 8], [-8, 8]);

axes(handles.axes4);
axes4handle = scatter([-8, 8], [-8, 8]);

axes(handles.axes5);
axes5handle = scatter([-8, 8], [-8, 8]);

handles.output = hObject;
guidata(hObject, handles);

ImPeriod = 2500 / 1000.0;  % 50ms
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
global axes1handle
global axes2handle
global axes3handle
global axes4handle
global axes5handle

datanum = length(channel0Data);
if datanum ~= 0
    [~, sampleRate] = getdatanum();
    [constellation, Picture] = PicDemodulator(channel2Data, sampleRate);
    png = Compress(Picture);
    imshow(png, 'parent', handles.axesPic);
    %set(axes1handle, 'XData', png);
    set(axes2handle, 'XData', rand(1, 100), 'YData', rand(1, 100));
    set(axes3handle, 'XData', rand(1, 100), 'YData', rand(1, 100));
    set(axes4handle, 'XData', constellation, 'YData', constellation);
    set(axes5handle, 'XData', rand(1, 100), 'YData', rand(1, 100));
end

%% Gui close func
function DeleteFcn(hObject, eventdata, t, handles)
stop(t);

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
