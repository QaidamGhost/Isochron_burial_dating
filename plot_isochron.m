function plot_isochron(a,sigma_a,b,sigma_b,linearized_data,data,removed_data,init_Rinh,option)
%function plot_isochron(a,b,sigma_b,linearized_data,data,removed_data,init_Rinh)

%% Plot the isochron line, production ratio line, and errorbars of samples and maximum estimation of post-burial concentration

%% Arguments:
% a: the intercept of the isochron line (atom/g/yr; scalar)
% sigma_a: 1 sigma absolute error of the intercept (atom/g/yr; scalar)
% b: the slope of the isochron line (unitless; scalar)
% sigma_b: 1 sigma absolute error of the slope (unitless; scalar)
% linearized_data must have fields as:
%   linearized_data.x: linearized 10Be concentration (atom/g; nx1 vector)
%   linearized_data.dx: 1 sigma absolute error of 10Be (atom/g; nx1 vector)
%   linearized_data.y: linearized 26Al concentration (atom/g; nx1 vector)
%   linearized_data.dy: 1 sigma absolute error of 26Al (atom/g; nx1 vector)
% data: measured data precluding reworked clasts (ditto)
% removed_data: measured data of reworked clasts (ditto)
% production_rate_ratio: production rate ratio of 26Al versus 10Be
% (unitless; scalar)
% option have fields as:
%   option.flag: "0" for default usage, "1" for york regression whose
%   intercept isfixed at zero, and "2" for protecting the added post-burial
%   data point from being removed (unitless; scalar)
%   option.Npb:
%       option.Npb.x: post-burial 10Be concentration (atom/g; scalar)
%       option.Npb.dx: 1 sigma absolute error of 10Be (atom/g; scalar)
%       option.Npb.y: post-burial 26Al concentration (atom/g; scalar)
%       option.Npb.dy: 1 sigma absolute error of 26Al (atom/g; scalar)

%% Output:
% void

    % find the range of axis x and y
    if removed_data.x(:,1)==-1
        total_x =[linearized_data.x data.x 0];
        total_dx=[linearized_data.dx data.dx 0];
        total_y =[data.y a 0];
        total_dy=[data.dy 0 0];
    else
        total_x =[linearized_data.x data.x removed_data.x 0];
        total_dx=[linearized_data.dx data.dx removed_data.dx 0];
        total_y =[data.y removed_data.y a 0];
        total_dy=[data.dy removed_data.dy 0 0];
    end
    [max_x,~]=max(total_x+total_dx);
    [min_x,~]=min(total_x-total_dx);
    [max_y,~]=max(total_y+total_dy);
    [min_y,~]=min(total_y-total_dy);
    if min_x==0
        X = linspace(0,max_x*1.1);
    else
        X = linspace(min_x*1.1-max_x*.1,max_x*1.1-min_x*.1);
    end

    % isochron line
    Y1 = b*X+a;
    % upper error line
    Y2 = (b+sigma_b)*X+a+sigma_a;
    % lower error line
    Y3 = (b-sigma_b)*X+a-sigma_a;
    % production ratio line
    Y4 = init_Rinh*X;
    if option.flag==0
        figure('Name','Original Isochron Burial Dating');
        plot(X,Y1,'k',X,Y2,'k--',X,Y3,'k--',X,Y4,'m'),
        title('Original Isochron Burial Dating'),
    elseif option.flag==1
        figure('Name','Minimum Isochron Burial Dating');
        plot(X,Y1,'b',X,Y2,'b--',X,Y3,'b--',X,Y4,'m'),
        title('Minimum Isochron Burial Dating'),
    elseif option.flag==2
        figure('Name','Maximum Isochron Burial Dating');
        plot(X,Y1,'r',X,Y2,'r--',X,Y3,'r--',X,Y4,'m'),
        title('Maximum Isochron Burial Dating'),
    end
    
    xlabel('10Be Concentration (atom/g)'),
    ylabel('26Al Concentration (atom/g)'),
    grid on;
    % reset the range of axis x and y
    if min_x==0
        if min_y==0
            axis([0,max_x*1.1,0,max_y*1.1]);
        else
            axis([0,max_x*1.1,min_y*1.1-max_y*.1,max_y*1.1-min_y*.1]);
        end
    else
        if min_y==0
            axis([min_x*1.1-max_x*.1,max_x*1.1-min_x*.1,0,max_y*1.1]);
        else
            axis([min_x*1.1-max_x*.1,max_x*1.1-min_x*.1,min_y*1.1-max_y...
                *.1,max_y*1.1-min_y*.1]);
        end
    end
    % plot errorbar
    hold on;
    if option.flag~=2
        errorbar(linearized_data.x,linearized_data.y,linearized_data.dx,...
            'horizontal','ko');
        errorbar(linearized_data.x,linearized_data.y,linearized_data.dy,'ko');
    else
        m=size(linearized_data.x,2);
        linearized_data.x(:,m)=[];
        linearized_data.dx(:,m)=[];
        linearized_data.y(:,m)=[];
        linearized_data.dy(:,m)=[];
        errorbar(linearized_data.x,linearized_data.y,linearized_data.dx,...
            'horizontal','ko');
        errorbar(linearized_data.x,linearized_data.y,linearized_data.dy,'ko');
    end
    errorbar(data.x,data.y,data.dx,'horizontal','o','Color',[.5 .5 .5]);
    errorbar(data.x,data.y,data.dy,'o','Color',[.5 .5 .5]);
    if removed_data.x(:,1)~=-1
    errorbar(removed_data.x,removed_data.y,removed_data.dx,'horizontal',...
        'o','Color',[1 0 0]);
    errorbar(removed_data.x,removed_data.y,removed_data.dy,'o','Color',...
        [1 0 0]);
    end
    hold off;
end
