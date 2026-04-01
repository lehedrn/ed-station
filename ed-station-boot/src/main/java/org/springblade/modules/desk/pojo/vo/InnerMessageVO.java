package org.springblade.modules.desk.pojo.vo;

import org.springblade.modules.desk.pojo.entity.InnerMessage;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "内部消息实体VO")
public class InnerMessageVO extends InnerMessage {
    
    @Schema(description = "消息类型名")
    private String messageTypeName;
    
    @Schema(description = "租户编号")
    private String tenantId;
}
