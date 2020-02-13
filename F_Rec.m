function varargout = F_Rec(varargin)
% F_REC MATLAB code for F_Rec.fig
%      F_REC, by itself, creates a new F_REC or raises the existing
%      singleton*.
%
%      H = F_REC returns the handle to a new F_REC or the handle to
%      the existing singleton*.
%
%      F_REC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in F_REC.M with the given input_image arguments.
%
%      F_REC('Property','Value',...) creates a new F_REC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before F_Rec_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to F_Rec_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help F_Rec

% Last Modified by GUIDE v2.5 29-Nov-2017 22:55:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @F_Rec_OpeningFcn, ...
                   'gui_OutputFcn',  @F_Rec_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before F_Rec is made visible.
function F_Rec_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to F_Rec (see VARARGIN)

% Choose default command line output for F_Rec
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.preview_image,'XTick',[],'YTick',[]);
set(handles.register_image,'XTick',[],'YTick',[]);
set(handles.input_image,'XTick',[],'YTick',[]);
set(handles.recognised_image,'XTick',[],'YTick',[]);

handles.data = load('E:\ImageProc\Gray Images\Registration\latest\temp\counter.mat');
% UIWAIT makes F_Rec wait for user response (see UIRESUME)
% uiwait(handles.figure1);

guidata(hObject,handles);
% --- Outputs from this function are returned to the command line.
function varargout = F_Rec_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

global vid;

vid =videoinput('winvideo',1,'YUY2_640x480');
hImage=image(zeros(620,560,3),'Parent',handles.preview_image);
preview(vid,hImage);


% --- Executes on button press in capture.
function capture_Callback(hObject, eventdata, handles)
% hObject    handle to capture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global vid;

set(vid,'ReturnedColorSpace','rgb');
capture=getsnapshot(vid);

imwrite(capture,'E:\ImageProc\Gray Images\Test\image.pgm','pgm');

face = vision.CascadeObjectDetector;
I = imread('E:\ImageProc\Gray Images\Test\image.pgm');
s = step(face,I);
for i = 1:size(s,1)
    rectangle('Position',s(i,:),'LineWidth',5,'LineStyle','-','EdgeColor','none');
end

f=imcrop(I,s);
imwrite(f,'E:\ImageProc\Gray Images\Test\image.pgm','pgm');

global r;
img=imread('E:\ImageProc\Gray Images\Test\image.pgm');
r=imresize(img,[92 112]);
imwrite(r,'E:\ImageProc\Gray Images\Test\image.pgm','pgm');
imshow(r,'Parent',handles.register_image);

% --- Executes on button press in register.
function register_Callback(hObject, eventdata, handles)
% hObject    handle to register (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global r;
global a;
handles.data.a=handles.data.a+1;
a=handles.data.a;
imwrite(r,sprintf('%d.jpg',a),'jpg');
uiwait(msgbox(sprintf('Registering image as %d',a),'MESSAGE'));
save('counter.mat','a');
guidata(hObject,handles);
% --- Executes on button press in check.
function check_Callback(hObject, eventdata, handles)
% hObject    handle to check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
total_image=43;
image_set=[];
for i=1:total_image
    str=strcat('E:\ImageProc\local_DB\newww_test\',int2str(i),'.jpg');
    img=imread(str);
    img=histeq(img);
    [irow icol]=size(img);
    temp=reshape(img,irow*icol,1);
    image_set=[image_set temp];
end
assignin('base','image_set',image_set);
clear i str img temp;


mean_image_set=mean(image_set,2);

clear m_mimg_set sd_mimg_set


assignin('base','mean_image_set',mean_image_set);

vec=[];
for i=1:total_image
    temp=(double(image_set(:,i))-mean_image_set);
    vec=[vec temp];
end
assignin('base','vec', vec);
clear i temp;
clear i temp1 mtni stni newd;

A=vec';
cv=A*A';
assignin('base','cv',cv);
[ivec ival]=eig(cv);


 u=[];
for i=1:size(ivec,2)
    temp=A'*ivec(:,i);
    u=[u temp];
end
assignin('base','u',u);

regd=[];
regim_d=[];
no_of_reg_im=handles.data.a;   %%%takes the counter value
for i=1:no_of_reg_im
    r=strcat('E:\ImageProc\Gray Images\Registration\latest\temp\',int2str(i),'.jpg');
    reg=imread(r);
    regdim=reshape(reg,irow*icol,1);
    %{
regim_d=[regim_d regdim];
    n_reg=histeq(reg);
    n_regdim=reshape(n_reg,irow*icol,1);
    %}
    regd=[regd regdim];
end

clear i r reg;



rmm=[];
for i=1:no_of_reg_im
    tm=double(regd(:,i))-mean_image_set;
    rmm=[rmm tm];
end

clear i tm;

wreg=[];
tempwtt=[];
for j=1:no_of_reg_im
    for i=1:total_image
        wtt=dot(u(:,i),rmm(:,j));
        tempwtt=[tempwtt wtt];
    end
end
wreg=reshape(tempwtt,total_image,no_of_reg_im);
wreg=wreg';

input=imread('E:\ImageProc\Gray Images\Test\image.pgm');
con1=input;
input=histeq(input);
con=reshape(input,icol*irow,1);


norm_ip_im=double(con)-mean_image_set;

clear con mcon scon;

sinput=[];
for i=1:total_image
     cop=dot(u(:,i),norm_ip_im);
    sinput=[sinput cop];
end

Eu_dist=[];
for i=1:no_of_reg_im
    Eminus=sinput-wreg(i,:);
    Epower=Eminus.^2;
    Esum=sum(Epower);
    Esqroot=sqrt(Esum);
    Eu_dist=[Eu_dist Esqroot];
end

assignin('base','Eu_dist',Eu_dist);
clear i Eminus Epower Esum Esqroot;
nano=min(Eu_dist);
c=1;
for i=1:no_of_reg_im
    if((Eu_dist(:,i)==nano));
        c=i;
    end
end
imshow(con1,'Parent',handles.input_image);
show=reshape(regd(:,c),irow,icol);
show=mat2gray(show);
imshow(show,'Parent',handles.recognised_image);
% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in about.
function about_Callback(hObject, eventdata, handles)
% hObject    handle to about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


msgbox('The Face Recognition System is used to recognise an unknown face by,comparing it with the images present in the database.If the database does not contain the image then you have the option of registering the image just by clicking the REGISTER BUTTON','ABOUT');


% --- Executes on button press in discard.
function discard_Callback(hObject, eventdata, handles)
% hObject    handle to discard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete('E:\ImageProc\Gray Images\Test\image.pgm');
cla(handles.register_image);
cla(handles.recognised_image);
cla(handles.input_image);
msgbox('Image is deleted');


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a;
handles.data.a=0;
a=handles.data.a;
save('counter.mat','a');
msgbox(sprintf('value of counter is set to %d',a));
guidata(hObject,handles);


% --- Executes on button press in instruction.
function instruction_Callback(hObject, eventdata, handles)
% hObject    handle to instruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'CAPTURE : TO CAPTURE THE FACE'; ;'REGISTER : TO REGISTER THE FACE'; ;'DISCARD : TO DELETE THE CAPTURED FACE'; ;'CHECK : TO RUN THE FACE RECOGNISING ENGINE'; ;'RESET : TO SET THE COUNTER TO 0'},'INSTUCTION');
