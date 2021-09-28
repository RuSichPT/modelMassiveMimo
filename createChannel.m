function [channel] = createChannel(prm)

    switch prm.typeChannel
        case "PHASED_ARRAY_STATIC"
            channel = CreateChannelByDN_static(prm.numUsers, prm.numDelayBeams, prm.txAng, prm.da, prm.dp); % ��� ��������� �����
        case "PHASED_ARRAY_DYNAMIC"
            channel = CreateChannelByDN(prm.numUsers, prm.numDelayBeams, prm.da, prm.dp); % ��������� ����
    end

end

