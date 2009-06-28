function tdtSetSoundAmplitude( TDT, freq )

invoke( TDT.RP, TDT.call_SetTag, [TDT.Dev{1} '.soundFreq'], freq);

