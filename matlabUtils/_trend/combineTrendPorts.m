function port = combineTrendPorts(port1,port2,port3,wts)
port = port1;
port.wts0 = wts(1)*port1.wts0+wts(2)*port2.wts0+wts(3)*port3.wts0;
port.wts = wts(1)*port1.wts+wts(2)*port2.wts+wts(3)*port3.wts;
port.pnl = wts(1)*port1.pnl+wts(2)*port2.pnl+wts(3)*port3.pnl;
port.tc = wts(1)*port1.tc+wts(2)*port2.tc+wts(3)*port3.tc;
port.totPnl = wts(1)*port1.totPnl+wts(2)*port2.totPnl+wts(3)*port3.totPnl;
port.targRisk = wts(1)*port1.targRisk+wts(2)*port2.targRisk+wts(3)*port3.targRisk;
port.actRisk = wts(1)*port1.actRisk+wts(2)*port2.actRisk+wts(3)*port3.actRisk;
for k = 1:length(port1.subStrat)
   port.subStrat(k) = port1.subStrat(k); 
   port.subStrat(k).wts = wts(1)*port1.subStrat(k).wts+...
                           wts(2)*port2.subStrat(k).wts+wts(3)*port3.subStrat(k).wts;
   port.subStrat(k).pnl = wts(1)*port1.subStrat(k).pnl+...
                           wts(2)*port2.subStrat(k).pnl+wts(3)*port3.subStrat(k).pnl;
   port.subStrat(k).tc = wts(1)*port1.subStrat(k).tc+...
                          wts(2)*port2.subStrat(k).tc+wts(3)*port3.subStrat(k).tc;
   port.subStrat(k).totPnl = wts(1)*port1.subStrat(k).totPnl+...
                              wts(2)*port2.subStrat(k).totPnl+wts(3)*port3.subStrat(k).totPnl;
   port.subStrat(k).targRisk = wts(1)*port1.subStrat(k).targRisk+...
                                wts(2)*port2.subStrat(k).targRisk+wts(3)*port3.subStrat(k).targRisk;
   port.subStrat(k).actRisk = [wts(1)*port1.subStrat(k).actRisk,...
                               wts(2)*port2.subStrat(k).actRisk+wts(3)*port3.subStrat(k).actRisk];
end % k
end % fn
