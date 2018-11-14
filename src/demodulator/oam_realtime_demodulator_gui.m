function varargout = oam_realtime_demodulator_gui(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @oam_realtime_demodulator_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @oam_realtime_demodulator_gui_OutputFcn, ...
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
function oam_realtime_demodulator_gui_OpeningFcn(hObject, eventdata, handles, varargin)

global t
global regs
global errors
global isopen
global isrenew
global card
global checkright
global checktotal
global channel_name
global datashownum
global channel0Data
global channel1Data
global channel2Data
global channel3Data
global channel0QPSK
global channel1QPSK
global channel2QPSK
global channel3QPSK
global ispic

channel0Data = [];
channel1Data = [];
channel2Data = [];
channel3Data = [];

channel0QPSK = [];
channel1QPSK = [];
channel2QPSK = [];
channel3QPSK = [];

regs = spcMCreateRegMap();
errors = spcMCreateErrorMap();
isopen = 0;
isrenew = 0;
card = 0;
checkright = 0;
checktotal = 0;
channel_name = {'Dat_Ch0', 'Dat_Ch1', 'Dat_Ch2', 'Dat_Ch3'};
datashownum = 5000;
conf = config();
ispic = conf(1);

handles.output = hObject;

guidata(hObject, handles);

if ispic == 1
    ImPeriod = 5000 / 1000.0;  % 5000ms
else
    ImPeriod = 600 / 1000.0;  % 600ms
end

t = timer('TimerFcn', {@timerCallback, handles}, 'ExecutionMode', 'fixedDelay', 'Period', ImPeriod);
set(handles.figure1, 'DeleteFcn', {@DeleteFcn, t, handles});

%% Gui output
function varargout = oam_realtime_demodulator_gui_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

%% timer func
function timerCallback(hObject, eventdata, handles)

global card
global figureRecDataCh0
global figureRecDataCh1
global figureRecDataCh2
global figureRecDataCh3
global figureRecDataCons
global checkright
global checktotal
global regs
global errors
global datashownum
global channel0Data
global channel1Data
global channel2Data
global channel3Data
global ispic

global channel0QPSK
global channel1QPSK
global channel2QPSK
global channel3QPSK

[ndatanum, sampleRate] = getdatanum();
sampleTime = 1 / sampleRate;
time = 0 : sampleTime : (ndatanum - 1) * sampleTime; 
[Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3] = ...
    card_read_data(card, regs, errors, sampleRate);

channel0Data = Dat_Ch0;
channel1Data = Dat_Ch1;
channel2Data = Dat_Ch2;
channel3Data = Dat_Ch3;

if ispic == 1
    QPSK = [1;2];
else
    %[channel0QPSK, channel1QPSK, channel2QPSK, channel3QPSK] = PolitDemodulator2(Dat_Ch0, Dat_Ch3, sampleRate);
    % [QPSK, ~] = PolitDemodulatorch3(Dat_Ch0, sampleRate);
    check = 1023;
    [channel1QPSK, ~] = PolitDemodulatorch1(channel1Data, sampleRate);
end

set(figureRecDataCh0, 'XData', time(1:datashownum), 'YData', Dat_Ch0(1:datashownum));
set(figureRecDataCh1, 'XData', time(1:datashownum), 'YData', Dat_Ch1(1:datashownum));
set(figureRecDataCh2, 'XData', time(1:datashownum), 'YData', Dat_Ch2(1:datashownum));
set(figureRecDataCh3, 'XData', time(1:datashownum), 'YData', Dat_Ch3(1:datashownum));

checktotal = checktotal + 1;
set(figureRecDataCons, 'XData', channel1QPSK(1,:), 'YData', channel1QPSK(2,:));
checkright = checkright + 1;

fprintf('check total count : %d check right count : %d\n', checktotal, checkright);

%% Gui close func
function DeleteFcn(hObject, eventdata, t, handles)
stop(t);
close_card(handles);

%% open card
function open_card(handles)
global card
global isopen
global regs
if isopen == 0
    [ndatanum, ~] = getdatanum();
    card = initcard(regs, ndatanum);
    isopen = 1;
end

%% close card
function close_card(handles)

global card
global isopen
if isopen == 1
    spcMCloseCard (card);
    fprintf('card is closed\r\n');
end

%% btnStart click delegate
function btnStart_Callback(hObject, eventdata, handles)

global isrenew
global t
global card
global figureRecDataCh0
global figureRecDataCh1
global figureRecDataCh2
global figureRecDataCh3
global figureRecDataCons
global regs
global errors
global datashownum
global ispic

axexrange = 10;
fontsize = 18;

open_card(handles);

axes(handles.axes2);
[ndatanum, sampleRate] = getdatanum();
sampleTime = 1 / sampleRate;
time = 0 : sampleTime : (ndatanum - 1) * sampleTime;  
[Dat_Ch0, Dat_Ch1, Dat_Ch2, Dat_Ch3] = ...
    card_read_data(card, regs, errors, sampleRate);
if ispic == 1
    QPSK = [1;2];
else
    % [QPSK, ~, ~, ~] = PolitDemodulator2(Dat_Ch0, Dat_Ch3, sampleRate);
    % check = 1023;
    [QPSK, check] = PolitDemodulatorch3(Dat_Ch0, sampleRate);
    fprintf('Demodulator check ok! check:%d\n', check);
end

figureRecDataCh0 = plot(time(1:datashownum), Dat_Ch0(1:datashownum), 'b');
hold on;
figureRecDataCh1 = plot(time(1:datashownum), Dat_Ch1(1:datashownum), 'g');
figureRecDataCh2 = plot(time(1:datashownum), Dat_Ch2(1:datashownum), 'r');
figureRecDataCh3 = plot(time(1:datashownum), Dat_Ch3(1:datashownum), 'y');
hold off;
legend('Channel0', 'Channel1', 'Channel2','Channel3');
set(gca, 'FontSize', fontsize);

axes(handles.axes1);
figureRecDataCons = scatter(QPSK(1,:), QPSK(2,:), 20, 'filled');
set(gca,'FontSize', fontsize);
%axis([-axexrange axexrange -axexrange axexrange]);

isrenew = 1;
start(t);

guidata(hObject, handles);

%% btnStop click delegate
function btnStop_Callback(hObject, eventdata, handles)
global isrenew
global t
isrenew = 0;
stop(t);
guidata(hObject, handles);

%% btnClose click delegate
function btnClose_Callback(hObject, eventdata, handles)
close_card(handles);
guidata(hObject, handles);
delete(handles.figure1)

%% menuPicFigure click delegate
function menuPicFigure_Callback(hObject, eventdata, handles)

pic_figure_name = 'oam_realtime_demodulator_pic_gui.fig';
h = guihandles; 
open(pic_figure_name);

%% menuUser click delegate
function menuUser_Callback(hObject, eventdata, handles)
pic_figure_name = 'oam_realtime_demodulator_user_gui.fig';
h = guihandles; 
open(pic_figure_name);
