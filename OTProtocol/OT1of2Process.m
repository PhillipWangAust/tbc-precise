function m_b = OT1of2Process(m, b)
if numel(m) ~= 2 || numel(b) ~= 1 || (b ~= 0 && b ~= 1)
    error('the provided value of m or b  is wrong in OT1of2Process!')
end
PA = PartA1of2(m);
PB = PartB1of2(b);

PB = PB.receiveXFromPartA(PA.sendX2PartB());
PB = PB.receivePubKeyFromPartA(PA.sendPubKey2PartB());
PB = PB.receiveNFromPartA(PA.sendN2PartB());

PA = PA.receiveVFromPartB(PB.sendv2PartA());

PB = PB.receiveMpFromPartA(PA.sendMp2PartB());

m_b = double(PB.getMb());
end