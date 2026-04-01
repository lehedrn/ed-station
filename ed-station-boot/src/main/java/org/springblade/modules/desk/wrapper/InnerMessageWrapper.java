package org.springblade.modules.desk.wrapper;

import java.util.Objects;

import org.springblade.common.cache.DictCache;
import org.springblade.common.enums.DictEnum;
import org.springblade.core.mp.support.BaseEntityWrapper;
import org.springblade.core.tool.utils.BeanUtil;
import org.springblade.modules.desk.pojo.entity.InnerMessage;
import org.springblade.modules.desk.pojo.vo.InnerMessageVO;

public class InnerMessageWrapper extends BaseEntityWrapper<InnerMessage, InnerMessageVO> {

    public static InnerMessageWrapper build() {
        return new InnerMessageWrapper();
    }

    @Override
    public InnerMessageVO entityVO(InnerMessage innerMessage) {
        InnerMessageVO innerMessageVO = Objects.requireNonNull(BeanUtil.copyProperties(innerMessage, InnerMessageVO.class));
        String messageTypeName = DictCache.getValue(DictEnum.MESSAGE_TYPE, innerMessageVO.getMessageType());
        innerMessageVO.setMessageTypeName(messageTypeName);
        return innerMessageVO;
    }

}
