from pyais import decode
import pynmea2

def aivdm_parse(msg):
    m = decode(msg.decode('utf-8'))
    if m.msg_type == 1:
        b = "1,"+str(m.lat)+","\
                +str(m.lon)+","\
                +str(m.course)+","\
                +str(m.speed)+","\
                +str(m.mmsi)+"\n"
        return b.encode('utf-8')
    elif m.msg_type == 5:
        shipname = m.shipname
        shipname = shipname.replace("\"", "DQ")
        n = "5,\""+str(shipname)+"\","+str(m.mmsi)+"\n"
        return n.encode('utf-8')

def gprmc_parse(msg):
    try:
        msg = pynmea2.parse(msg.decode('utf-8'))
        if type(msg) is pynmea2.types.talker.RMC:
            onb = "\""+str(msg.timestamp)+"\","\
                      +str(msg.latitude)+","\
                      +str(msg.longitude)+","\
                      +str(msg.true_course)+","\
                      +str(msg.spd_over_grnd)+","\
                  "\""+str(msg.datestamp)+"\"\n"
            return onb.encode('utf-8')
#        elif type(msg) is pynmea2.types.talker.MWV:
#           wda = "(wind-angle "+str(msg.wind_angle)+")\r\n"
#           return wda.encode('utf-8')
#       elif type(msg) is pynmea2.types.talker.VWR:
#           wds = "(wind-speed "+str(msg.wind_speed_kn)+")\r\n"
#           return wds.encode('utf-8')
    except pynmea2.ParseError as e:
        print('Parse error: {}'.format(e))