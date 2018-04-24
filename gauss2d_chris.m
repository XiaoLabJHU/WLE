function [Para resnorm jacobian] = gauss2d_chris(Im,angle)
% fit the image with a 2D gaussian function with a known angle(the angle
% between short axis and X, usually use 0
% output is Para = [signal, centerX, centerY,sigmaX,sigmaY,offset];
%           resnorm and jacobian are from nonlinear fitting itself
%%
        Reg = Im;
        N = size(Im,1);
        M = size(Im,2);
        MeanAng = angle;
        options = optimoptions('lsqcurvefit','Display','off');
        Z = double(reshape(Reg,[size(Reg,1)*size(Reg,2) 1]));
        [xmesh ymesh] = meshgrid([1:size(Reg,2)],[1:size(Reg,1)]);
        xdata(:,1) = reshape(xmesh,[size(xmesh,1)*size(xmesh,2) 1]);
        xdata(:,2) = reshape(ymesh,[size(ymesh,1)*size(ymesh,2) 1]);
        % fit the rotated 2D gaussian function
        % set the initial parameters
        parax(1) = max(Reg(:))-min(Reg(:));
        parax(2) = N/2;
        parax(3) = 1;
        parax(4) = M/2;
        parax(5) = 1;
        parax(6) = min(Reg(:));
        lb = [0,0,0,0,0,0];
        ub = [2*parax(1),N,M,N,M,max(Reg(:))];
        [paraf,resnorm,residual,exitflag,output,lambda,jacobian]  = lsqcurvefit(@(x,xdata)gauss2dFixAngle(x,MeanAng,xdata),parax,xdata,Z,lb,ub,options);
        % record the useful parameters
        Para(1) = pi*paraf(1)*paraf(3)*paraf(5);% signal level
        Para(2) = paraf(2); % centerX
        Para(3) = paraf(4); % centerY
        Para(4) = paraf(3); % sigmaX
        Para(5) = paraf(5); % sigmaY 
        Para(6) = paraf(6); % offset
        
end
%%
function Y = gauss2dFixAngle( x, angle, xdata )
% function of 2D gaussian for fitting
%   x(1): amplitude
%   x(2): x position
%   x(3): sigmaX
%   x(4): y position
%   x(5): sigmaY
%   x(6): the background intensity
%   angle: the angle between x and main axis
%   By Xinxing Yang 20170806

xdatarot(:,1)= xdata(:,1)*cos(angle) - xdata(:,2)*sin(angle);
xdatarot(:,2)= xdata(:,1)*sin(angle) + xdata(:,2)*cos(angle);
x0rot = x(2)*cos(angle) - x(4)*sin(angle);
y0rot = x(2)*sin(angle) + x(4)*cos(angle);

Y = x(1)*exp(-((xdatarot(:,1)-x0rot).^2/(2*x(3)^2) + (xdatarot(:,2)-y0rot).^2/(2*x(5)^2))) + x(6);

end
