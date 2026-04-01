package org.springblade.modules.desk.pojo.entity;

import java.io.Serial;
import java.time.LocalDateTime;

import org.springblade.core.tenant.mp.TenantEntity;
import org.springblade.core.tool.utils.DateUtil;
import org.springframework.format.annotation.DateTimeFormat;

import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("blade_inner_message")
@Schema(description = "内部消息实体类")
public class InnerMessage extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "标题")
    private String title;
    
    @Schema(description = "消息类型")
    private Integer messageType;
    
    @Schema(description = "发布时间")
    @DateTimeFormat(pattern = DateUtil.PATTERN_DATETIME)
	@JsonFormat(pattern = DateUtil.PATTERN_DATETIME)
    private LocalDateTime releaseTime;
    
    @Schema(description = "消息内容")
    private String messageContent;
}


/* CREATE TABLE `blade_inner_message`  (
  `id` bigint NOT NULL COMMENT '主键',
  `tenant_id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '000000' COMMENT '租户ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标题',
  `message_type` int NULL DEFAULT NULL COMMENT '消息类型',
  `release_time` datetime NULL DEFAULT NULL COMMENT '发布时间',
  `message_content` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '消息内容',
  `create_user` bigint NULL DEFAULT NULL COMMENT '创建人',
  `create_dept` bigint NULL DEFAULT NULL COMMENT '创建部门',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_user` bigint NULL DEFAULT NULL COMMENT '修改人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `status` int NULL DEFAULT 1 COMMENT '状态',
  `is_deleted` int NULL DEFAULT 0 COMMENT '是否已删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '内部消息';
 */