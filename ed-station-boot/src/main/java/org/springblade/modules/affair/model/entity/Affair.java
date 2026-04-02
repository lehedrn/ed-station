/**
 * BladeX Commercial License Agreement
 * Copyright (c) 2018-2099, https://bladex.cn. All rights reserved.
 * <p>
 * Use of this software is governed by the Commercial License Agreement
 * obtained after purchasing a license from BladeX.
 * <p>
 * 1. This software is for development use only under a valid license
 * from BladeX.
 * <p>
 * 2. Redistribution of this software's source code to any third party
 * without a commercial license is strictly prohibited.
 * <p>
 * 3. Licensees may copyright their own code but cannot use segments
 * from this software for such purposes. Copyright of this software
 * remains with BladeX.
 * <p>
 * Using this software signifies agreement to this License, and the software
 * must not be used for illegal purposes.
 * <p>
 * THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY. The author is
 * not liable for any claims arising from secondary or illegal development.
 * <p>
 * Author: coderleehd
 */
package org.springblade.modules.affair.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springblade.core.datarecord.annotation.DataRecord;
import org.springblade.core.datarecord.annotation.DataRecordLevel;
import org.springblade.core.tenant.mp.TenantEntity;

import java.io.Serial;
import java.util.Date;

/**
 * 政务服务事项实体类
 *
 * @author coderleehd
 * @since 2026-04-02
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("blade_affair")
@DataRecord(
    module = "政务服务",
    operation = "事项管理",
    level = DataRecordLevel.INFO
)
@Schema(description = "政务服务事项实体类")
public class Affair extends TenantEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 事项名称
     */
    @Schema(description = "事项名称")
    private String affairName;

    /**
     * 事项简称
     */
    @Schema(description = "事项简称")
    private String affairShortName;

    /**
     * 实施编码 (系统自动生成)
     */
    @Schema(description = "实施编码")
    private String implementCode;

    /**
     * 事项类别 (字典 affair_type)
     */
    @Schema(description = "事项类别")
    private String affairType;

    /**
     * 法定时限 (工作日)
     */
    @Schema(description = "法定时限")
    private Integer legalLimit;

    /**
     * 承诺时限 (工作日，≤法定时限)
     */
    @Schema(description = "承诺时限")
    private Integer promiseLimit;

    /**
     * 办理条件 (富文本 HTML)
     */
    @Schema(description = "办理条件")
    private String handleCondition;

    /**
     * 备注说明
     */
    @Schema(description = "备注说明")
    private String remark;

    /**
     * 发布时间
     */
    @Schema(description = "发布时间")
    private Date publishTime;

    /**
     * 状态 (1-正常 2-下架)
     */
    @Schema(description = "状态")
    private Integer status;

}
