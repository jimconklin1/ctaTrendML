function [CTickerPrcUS,CTickerSprdUS,CTickerSprdEur,CTickerSprdAus,CTickerSprdJap,CTickerSprd,CTickerGen,cdxUSprc,cdxUSsprd,cdxEur,cdxAus,cdxJap,cdxPrc,cdxSprd,CTicker,CTickerAll] = tickerSeries(series)
    % pull price for tickers that only have spread using 'getdata' function
        
    CTickerPrcUS =  {'CDX EM CDSI SSS 5Y PRC Corp','CDX HY CDSI SSS 5Y PRC Corp'}; % tickers that have prices(not spreads) in bloomberg; will pull historical data using 'history' function    
    CTickerSprdUS = {'CDX IG CDSI SSS 5Y Corp'};
    CTickerSprdEur = {'SNRFIN CDSI SSS 5Y Corp','ITRX EUR CDSI SSS 5Y Corp','ITRX XOVER CDSI SSS 5Y Corp','SUBFIN CDSI SSS 5Y Corp'}; % tickers that only have spreads in bloomberg; will pull quoted price using
    CTickerSprdAus = {'ITRX AUS CDSI SSS 5Y Corp'}; % tickers that only have spreads in bloomberg; will pull quoted price using
    CTickerSprdJap = {'ITRX JAPAN CDSI SSS 5Y Corp'}; % tickers that only have spreads in bloomberg; will pull quoted price using
    
    cdxUSprc = {'CXPEM5SS CBIN Curncy','CXPHY5SS CBIN Curncy'};
    cdxUSsprd = {'CDXIG5SS CBIN Curncy'};
    cdxEur = {'ITXES5SS CBIL Curncy','ITXEB5SS CBIL Curncy','ITXEX5SS CBIL Curncy','ITXEU5SS CBIL Curncy'};
    cdxAus = {'ITXAA5SS CBIT Curncy'};
    cdxJap = {'ITXAJ5SS CBIT Curncy'};
    
    CTickerPrcUS =  strrep(CTickerPrcUS,'SSS',strcat('S',num2str(series)));   
    CTickerSprdUS = strrep(CTickerSprdUS,'SSS',strcat('S',num2str(series)));   
    CTickerSprdEur = strrep(CTickerSprdEur,'SSS',strcat('S',num2str(series)));   
    CTickerSprdAus = strrep(CTickerSprdAus,'SSS',strcat('S',num2str(series)));   
    CTickerSprdJap = strrep(CTickerSprdJap,'SSS',strcat('S',num2str(series)));  
    
    cdxUSprc = strrep(cdxUSprc,'SS',num2str(series));
    cdxUSsprd = strrep(cdxUSsprd,'SS',num2str(series));
    cdxEur = strrep(cdxEur,'SS',num2str(series));
    cdxAus = strrep(cdxAus,'SS',num2str(series));
    cdxJap = strrep(cdxJap,'SS',num2str(series));
 

    CTickerSprd = [CTickerSprdUS CTickerSprdEur CTickerSprdAus CTickerSprdJap];
    CTickerGen = [CTickerPrcUS CTickerSprd];
    CTickerAll = {'CDX EM CDSI GEN 5Y PRC Corp','CDX HY CDSI GEN 5Y PRC Corp','CDX IG CDSI GEN 5Y Corp','SNRFIN CDSI GEN 5Y Corp',...
        'ITRX EUR CDSI GEN 5Y Corp','ITRX XOVER CDSI GEN 5Y Corp','SUBFIN CDSI GEN 5Y Corp',...
        'ITRX AUS CDSI GEN 5Y Corp','ITRX JAPAN CDSI GEN 5Y Corp'};
    
    cdxPrc = cdxUSprc;
    cdxSprd = [cdxUSsprd cdxEur cdxAus cdxJap];    
    CTicker = [cdxPrc cdxSprd];


end

    