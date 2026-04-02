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
package org.springblade.modules.affair.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

/**
 * 政务服务事项修改视图类
 *
 * @author coderleehd
 * @since 2026-04-02
 */
@Data
@Schema(description = "政务服务事项修改视图类")
public class AffairUpdateVO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 主键 ID
     */
    @Schema(description = "主键 ID", required = true)
    @NotNull(message = "主键 ID 不能为空")
    private Long id;

    /**
     * 事项名称
     */
    @Schema(description = "事项名称", required = true)
    @NotBlank(message = "事项名称不能为空")
    private String affairName;

    /**
     * 事项简称
     */
    @Schema(description = "事项简称")
    private String affairShortName;

    /**
     * 事项类别
     */
    @Schema(description = "事项类别", required = true)
    @NotBlank(message = "事项类别不能为空")
    private String affairType;

    /**
     * 法定时限 (工作日)
     */
    @Schema(description = "法定时限", required = true)
    @NotNull(message = "法定时限不能为空")
    private Integer legalLimit;

    /**
     * 承诺时限 (工作日)
     */
    @Schema(description = "承诺时限", required = true)
    @NotNull(message = "承诺时限不能为空")
    private Integer promiseLimit;

    /**
     * 办理条件 (富文本 HTML)
     */
    @Schema(description = "办理条件", required = true)
    @NotBlank(message = "办理条件不能为空")
    private String handleCondition;

    /**
     * 备注说明
     */
    @Schema(description = "备注说明")
    private String remark;

    /**
     * 材料列表
     */
    @Schema(description = "材料列表")
    @Valid
    private List<MaterialSaveVO> materials;

}
