#OneDrop
#Control
#4/4
#24 bar blues sequence
#2 bar phrases
use_bpm 140

# Shout sample
# https://freesound.org/people/bolkmar/sounds/469308/ by bolkmar

samples = "~/Music/Sonic-Pi/one drop/samples"
load_samples samples

e = [:E4,  :G4, :B4]
a = [:A4,  :C5, :E5]
b = [:B4,  :Ds5,:Fs5]
seq = [e,e,e,e,e,e,e,e, a,a,a,a,e,e,e,e, b,b,b,b,e,e,e,e].ring

with_fx :reverb, mix: 0.1, room: 0.8 do |verb|
  
  live_loop "24bar" do
    sync "/cue/bar"
    cue "24bar1"
    sleep 7*4
    cue "24bar8"
    cue "24barchange"
    sleep 8*4
    cue "24bar16"
    cue "24barchange"
    sleep 8*4
    cue "24bar24"
    #cue "24barchange"
  end
  
  live_loop "phrase" do
    sync "/cue/bar"
    cue "phrase"
    
    time_warp 32.0-rt(0.07) do
      use_osc "127.0.0.1", 4561
      osc "/pulse", 49
    end
    sleep 8
  end
  
  live_loop "bar" do
    time_warp 4.0*(1-1.0/32) do
      set :currentchord, seq.tick
    end
    set :barnumber, tick("barnumber")+1
    if look("barnumber")==0 then
      set :verb, verb
    end
    control get[:verb], mix: 0.3
    sleep 4
    cue "bar"
  end
  
  
  live_loop "fill" do
    sync "/cue/24bar24"
    if dice(6)>2 then
      in_thread do
        a = 0.1
        s = 0.15
        if dice(3)>1 then
          sample :drum_splash_hard, amp: a*2
        end
        
        sleep 0.5
        if dice(3)>1 then
          sample :drum_splash_hard, amp: a*2
        end
        
        sleep 1.0+s
        sample :drum_tom_hi_hard, amp: a
        sleep 0.5-s
        sample :drum_tom_hi_hard, amp: a
        sleep 0.5+s
        sample :drum_tom_lo_hard, amp: a
        sleep 0.5-s
        sample :drum_tom_lo_hard, amp: a
        sleep 0.5
        if dice(3) > 1 then
          sample :drum_tom_lo_hard, amp: a
        end
        sleep [0,0.5].choose
        if dice(3)>1 then
          sample :drum_splash_hard, amp: a*2
        end
      end
    end
  end
  
  live_loop "openhat" do
    sync "/cue/phrase"
    if dice(12)>10 and get(:barnumber) > 24 then
      with_fx :reverb, mix: 0.7, dry: 0.1 do
        sleep 14
        sample :drum_cymbal_soft, amp: rrand(0.02,0.2)
      end
    end
  end
  
  live_loop "hihatpedal" do
    sync "/cue/bar"
    in_thread do
      4.times do
        sleep 1
        sample :drum_cymbal_pedal, amp: 0.3, lpf: 100.0+20.0*Math::sin(vt/2.0)
        sleep 1
      end
    end
  end
  
  
  live_loop "hihat" do
    sync "/cue/bar"
    s  = 0.15
    h0 = [0,1,1,1]
    h1 = [1, 0.5+s, 0.5-s, 0.5+s, 0.5-s, 0.5+s, 0.5-s]
    h2 = [0,1,1,1,0.5+s,0.4-s]
    h3 = [0,1,1,1,2.0/3]
    h4 = [1, 1.0/3,1.0/3,1.0/3,1]
    h5 = [1.0/3,1.0/3,1.0/3, 1.0/3,1.0/3,1.0/3, 1]
    h6 = [2.0/3,1.0/3, 2.0/3,1.0/3, 0.5+s, 0.5-s, 0.5+s, 0.5-s]
    
    if get(:barnumber) < 24 then
      pattern = [h0,h1].tick("intro")
    else
      pattern = [h0,h1,h2,h3,h4,h5,h6].choose
    end
    n = pattern.length
    tick_reset
    with_fx :reverb do |r|
      m = 0.4 + 0.3*(1.0+Math::sin(vt/3.2347)) / 2.0
      control r, mix: m, room: 0.5, damp: 0.1
      in_thread do
        n.times do
          sleep pattern.tick
          sample :drum_cymbal_closed, amp: 0.3, lpf: 120.0+9.0*Math::sin(vt/4.1)
        end
      end
    end
  end
  
  live_loop "bell" do
    sync "/cue/phrase"
    if dice(6)>3 and get(:barnumber)>24 then
      sleep 2
      sample :perc_bell2, amp: 0.2, pitch: 0
    end
  end
  
  live_loop "kick" do
    sync "/cue/bar"
    if dice(12) > 6 and get(:barnumber)>24 then
      in_thread do
        with_fx :echo do |e|
          m = 0.1 + 0.6*(1.0+Math::sin(vt/4.0)) / 2.0
          control e, mix: rrand(0.3,0.7), phase: [1.0/4, 1.0/3, 1.5].choose, decay: [3,5,10].choose
          sleep 2
          sample :bd_mehackit, amp: rrand(0.2,0.4)
        end
      end
    end
  end
  
  live_loop "bigechobass" do
    sync "/cue/24barchange"
    if dice(6)>3 and get(:barnumber)>24 then
      #with_fx :echo, decay: 12.0, phase: [1.0/4,1.0/2,3.0/2].tick do
      #  sleep 2
      #  sample :bd_mehackit, amp: 0.15
      #end
      a=1.2
      sleep 2
      case dice(3)
      when 1
        sample samples, "bigechobass-1.ogg", amp: a
      when 2
        sample samples, "bigechobass-2.ogg", amp: a
      when 3
        sample samples, "bigechobass-3.ogg", amp: a
      end
    end
  end
  
  
  live_loop "bass" do
    sync "/cue/phrase"
    if dice(6)>0 and get(:barnumber)>0 then
      in_thread do
        with_fx :echo, decay: 8.0 do |e|
          with_fx :bpf, amp: 1.0, mix: 0.8, res: 0.7 do |f|
            c = get(:currentchord)
            control e, mix: rrand(0.1,0.5), phase: 1.5
            4.times do
              control f, centre: 50 + 10*(1.0+Math::sin(vt/2.8))
              synth :sine, note: c.tick-24, amp: 0.4
              sleep 1
            end
          end
        end
      end
    end
  end
  
  live_loop "backbeat" do
    sync "/cue/bar"
    if dice(6) > 0
      in_thread do
        with_fx :echo, decay: 8.0 do |e|
          c = get(:currentchord)
          control e, mix: 0.4, phase: 3.0/2
          use_synth :beep
          sleep 1
          play_chord c, amp: 0.3, release: 0.3
          sleep 2
          play_chord c, amp: 0.3, release: 0.3
        end
      end
    end
  end
  
  live_loop "warble" do
    sync "/cue/bar"
    if dice(6)>5 and get(:barnumber)>24 then
      in_thread do
        with_fx :echo do |e|
          notes = [:E4, :B4].ring
          
          control e, mix: rrand(0.2,0.5), phase: 1.0/2
          #control r, mix: 0.5, room: 0.8, damp: 0.1
          
          use_synth :mod_tri
          play note: notes.choose, attack: 1.0, sustain: 1, release: 1.0, amp: 0.05, phase: 2.0/3
          
        end
      end
    end
  end
  
  live_loop "samples" do
    sync "/cue/bar"
    if get(:barnumber)>24 then
      case dice(12)
      when 1
        sample samples, "siren.ogg", amp: 0.8, attack: 0.0, sustain: 1.0, release: 1.0
      when 2,3
        with_fx :echo, mix: rrand(0.0,0.5), phase: 1.5, decay: 8.0 do
          sleep 1
          n = rrand(1,4)
          n.times do
            sample samples, "shout.ogg", amp: 0.6
            sleep 2
          end
        end
      end
    end
  end
end





