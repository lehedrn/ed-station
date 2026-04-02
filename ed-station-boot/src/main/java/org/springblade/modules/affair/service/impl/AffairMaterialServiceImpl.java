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
package org.springblade.modules.affair.service.impl;

import lombok.AllArgsConstructor;
import org.springblade.core.mp.base.BaseServiceImpl;
import org.springblade.modules.affair.mapper.AffairMaterialMapper;
import org.springblade.modules.affair.model.entity.AffairMaterial;
import org.springblade.modules.affair.service.IAffairMaterialService;
import org.springframework.stereotype.Service;

/**
 * 政务服务事项材料关联 Service 实现类
 *
 * @author coderleehd
 * @since 2026-04-02
 */
@Service
@AllArgsConstructor
public class AffairMaterialServiceImpl extends BaseServiceImpl<AffairMaterialMapper, AffairMaterial> implements IAffairMaterialService {

}
